# frozen_string_literal: true

require 'dry/events/publisher'

class App
  class AppError < StandardError; end

  APP_EXCEPTION_FORMAT = 'Exception in processing Plugin=%s for %s=%s due to Error=%s'

  include Import[:logger, :config]
  include Import[
    domain_detector: 'plugins.generic.domain_detector_plugin',
    scheme_detector: 'plugins.generic.scheme_detector_plugin'
  ]

  include Dry::Events::Publisher[:app_publisher]
  register_event :checked

  def call(domain_name, plugins)
    domain = detect_domain!(domain_name)
    scheme = detect_scheme!(domain)

    check(plugins, default_opts(scheme, domain))
  rescue AppError => e
    logger.fatal e.message
  end

  protected

  def detect_domain!(domain_name)
    started_at = Time.now.to_f

    report = domain_detector.call(domain: domain_name)

    return report.value![:domain] if report.success?

    publish_event(opts: { domain: domain_name }, meta: {}, report: report, started_at: started_at)

    raise AppError, format_exception(domain_detector, 'Domain', domain_name, report)
  end

  def detect_scheme!(domain_name)
    started_at = Time.now.to_f

    report = scheme_detector.call(domain: domain_name)

    return report.value![:scheme] if report.success?

    publish_event(opts: { domain: domain_name }, meta: {}, report: report, started_at: started_at)

    raise AppError, format_exception(scheme_detector, 'Domain', domain_name, report)
  end

  def default_opts(scheme, domain)
    {
      scheme: scheme,
      domain: domain,
      host: "#{scheme}://#{domain}"
    }
  end

  def check(requested_plugins, opts)
    requested_plugins.each do |namespace, plugins|
      enabled(plugins).each do |plugin_name, meta|
        started_at = Time.now.to_f
        report     = plugin(namespace, plugin_name).call(opts.merge(meta: meta))
        meta       = meta.delete_if { |k, _| k == :enable }

        publish_event(opts: opts, meta: meta, report: report, started_at: started_at)
      end
    end
  end

  def publish_event(opts:, meta:, report:, started_at:)
    publish(:checked, opts: opts, meta: meta, report: report, took: calculate_time_in_ms(started_at))
  end

  def enabled(plugins)
    plugins.delete_if { |_, meta| meta[:enable] != 1 }
  end

  def plugin(namespace, plugin_name)
    Application.resolve("plugins.#{namespace}.#{plugin_name}_plugin")
  end

  def format_exception(instance, entity, value, report)
    format(APP_EXCEPTION_FORMAT, instance.class, entity, value, report.failure)
  end

  def calculate_time_in_ms(started_at)
    (1000 * (Time.now.to_f - started_at)).to_i
  end
end
