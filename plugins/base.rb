# frozen_string_literal: true

module Plugins
  class PluginError < StandardError; end

  # Base class
  class Base
    def call(_)
      raise NotImplementedError
    end

    def name
      raise NotImplementedError
    end

    private

    # rubocop:disable Metrics/MethodLength
    def request_head(domain_name, resource)
      url = URI.parse(domain_name)

      begin
        http = Net::HTTP.start(url.host, url.port, open_timeout: 5, read_timeout: 5, use_ssl: url.port == 443)
        begin
          http.head(resource)
        rescue Timeout::Error
          raise PluginError, 'Timeout reading from server'
        end
      rescue Timeout::Error
        raise PluginError, 'Timeout connecting to server'
      rescue SocketError
        raise PluginError, 'Unknown server'
      rescue StandardError => e
        raise PluginError, "Unhandled exception: #{e.message}"
      end
    end
    # rubocop:enable Metrics/MethodLength

    def check_for_unexpected_status_code(response, expected)
      code = response.code.to_i

      raise PluginError, "Expected #{expected} HTTP Status Code, got: #{code}" unless code == expected
    end

    def check_for_unexpected_location(response, expected)
      location = response.header['Location']

      raise PluginError, "Expected #{expected} Location, got: #{location}" unless location == expected
    end

    def fetch(url, limit = 10)
      raise PluginError, 'Too many HTTP redirects' if limit.zero?

      get_response(url, limit)
    rescue Timeout::Error
      raise PluginError, 'Timeout connecting to server'
    rescue SocketError
      raise PluginError, 'Unknown server'
    rescue StandardError => e
      raise PluginError, e.message
    end

    def get_response(url, limit)
      response = Net::HTTP.get_response(URI(url))

      case response
      when Net::HTTPSuccess
        response
      when Net::HTTPRedirection
        fetch(response['location'], limit - 1)
      else
        response.value
      end
    end

    def success
      Result.new(success: true)
    end

    def failure(description)
      Result.new(success: false, description: description)
    end
  end
end
