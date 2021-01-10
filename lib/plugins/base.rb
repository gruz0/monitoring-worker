# frozen_string_literal: true

require 'dry/monads'

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

    def error_message
      'Expected %s, got %s'
    end

    def format_error_message(expected, got)
      format(error_message, expected, got)
    end

    def check_for_unexpected_status_code(url, response, expected)
      code = response.code.to_i

      return if code == expected

      raise PluginError, format_error_message("URL [#{url}] returns [#{expected}] HTTP Status Code", code)
    end

    def check_for_unexpected_location(url, response, expected)
      message = "URL [#{url}] returns Location [#{expected}] in Response Headers"

      location = response.header['Location'].to_s

      raise PluginError, format_error_message(message, 'empty') if location.empty?

      return if location == expected

      raise PluginError, format_error_message(message, location)
    end

    def success(value = nil)
      Success(result(value))
    end

    def failure(value)
      Failure(result(value))
    end

    def result(value)
      {
        plugin_class: self.class.name.to_s,
        plugin_name: name,
        value: value
      }
    end

    def prepare(*args)
      raise NotImplementedError
    end
  end
end
