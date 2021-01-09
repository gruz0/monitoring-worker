# frozen_string_literal: true

require 'import'

class App
  include Import[:logger, :config]

  def call
    domain = detect_domain!(config.domain)
    scheme = detect_scheme!(domain)

    result = check(config.plugins, default_opts(scheme, domain))

    result.each do |r|
      logger.debug r
    end
  rescue StandardError => e
    logger.fatal "App#run StandardError: #{e.message}"

    exit 1
  end

  private

  def detect_domain!(domain_name)
    domain_detector = plugin(:generic, :domain_detector).call(domain_name)

    return domain_detector.value![:value] if domain_detector.success?

    raise StandardError, domain_detector.failure[:value]
  end

  def detect_scheme!(domain_name)
    scheme_detector = plugin(:generic, :scheme_detector).call(domain_name)

    return scheme_detector.value![:value] if scheme_detector.success?

    raise StandardError, scheme_detector.failure[:value]
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
        next unless meta.enable

        result << plugin(namespace, plugin_name).call(opts.merge(meta: meta))
      end
    end

    result
  end

  def plugin(namespace, plugin_name)
    Application.resolve("plugins.#{namespace}.#{plugin_name}_plugin")
  end
end
