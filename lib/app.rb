# frozen_string_literal: true

class App
  class AppError < StandardError; end

  APP_EXCEPTION_FORMAT = 'Exception in processing Plugin=%s for %s=%s due to Error=%s'

  include Import[:logger, :config]
  include Import[
    domain_detector: 'plugins.generic.domain_detector_plugin',
    scheme_detector: 'plugins.generic.scheme_detector_plugin'
  ]

  def call(domain_name, plugins)
    domain = detect_domain!(domain_name)
    scheme = detect_scheme!(domain)

    check(plugins, default_opts(scheme, domain))
  rescue AppError => e
    logger.fatal e.message

    exit 1
  end

  protected

  def detect_domain!(domain_name)
    result = domain_detector.call(domain_name)

    return result.value![:domain] if result.success?

    raise AppError, format_exception(domain_detector, 'Domain', domain_name, result)
  end

  def detect_scheme!(domain_name)
    result = scheme_detector.call(domain_name)

    return result.value![:scheme] if result.success?

    raise AppError, format_exception(scheme_detector, 'Domain', domain_name, result)
  end

  def default_opts(scheme, domain)
    {
      scheme: scheme,
      domain: domain,
      host: "#{scheme}://#{domain}"
    }
  end

  def check(requested_plugins, opts)
    result = []

    requested_plugins.each do |namespace, plugins|
      plugins.each do |plugin_name, meta|
        next unless meta[:enable]

        result << plugin(namespace, plugin_name).call(opts.merge(meta: meta))
      end
    end

    result
  end

  def plugin(namespace, plugin_name)
    Application.resolve("plugins.#{namespace}.#{plugin_name}_plugin")
  end

  def format_exception(instance, entity, value, result)
    format(APP_EXCEPTION_FORMAT, instance.class, entity, value, result.failure)
  end
end
