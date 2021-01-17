# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Plugins
  class PluginError < StandardError; end

  # Base class
  class Base
    include Import[:logger, :http_client]
    include Dry::Monads[:result]

    def call(_)
      raise NotImplementedError
    end

    def name
      raise NotImplementedError
    end

    private

    def validate_opts(opts)
      scheme = opts.fetch(:scheme) { return Failure('Scheme must be present') }
      domain = opts.fetch(:domain) { return Failure('Domain must be present') }
      host   = opts.fetch(:host) { return Failure('Host must be present') }

      scheme = scheme.to_s.strip
      domain = domain.to_s.strip
      host   = host.to_s.strip

      return Failure('Scheme must not be empty') if scheme.empty?
      return Failure('Domain must not be empty') if domain.empty?
      return Failure('Host must not be empty') if host.empty?

      return Failure('Scheme must be one of: http or https') unless scheme.start_with?('http', 'https')
      return Failure('Domain must not have a scheme') if valid_scheme?(domain)

      return Failure('Host has invalid value') if host != "#{scheme}://#{domain}"

      Success(
        scheme: scheme,
        domain: domain,
        host: "#{scheme}://#{domain}"
      )
    end

    def request_head(host, resource)
      http_client.head(host, resource)
    end

    def request_get(url)
      http_client.get(url)
    end

    def check_for_unexpected_status_code(url, code, expected)
      return Success(code) if code == expected

      Failure(format_error_message("URL [#{url}] returns [#{expected}] HTTP Status Code", code))
    end

    def check_for_unexpected_location(url, location, expected)
      message = "URL [#{url}] returns Location [#{expected}] in Response Headers"

      return Failure(format_error_message(message, 'empty')) if location.empty?

      return Success(location) if location == expected

      Failure(format_error_message(message, location))
    end

    def valid_scheme?(url)
      url.start_with?('http://', 'https://')
    end

    def build_presentation(response)
      Success(plugin_meta.merge(response))
    end

    protected

    def plugin_meta
      {
        plugin_class: self.class.name.to_s,
        plugin_name: name
      }
    end

    def format_error_message(expected, got)
      format(error_message, expected, got)
    end

    def error_message
      'Expected %s, got %s'
    end
  end
end
