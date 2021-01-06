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

    def check_for_unexpected_status_code(response, expected)
      code = response.code.to_i

      return if code == expected

      raise PluginError, "Expected #{expected} HTTP Status Code, got: #{code}"
    end

    def check_for_unexpected_location(response, expected)
      location = response.header['Location']

      return if location == expected

      raise PluginError, "Expected #{expected} Location, got: #{location}"
    end

    def success(value = nil)
      Result.new(
        success: true,
        plugin_name: name,
        value: value
      )
    end

    def failure(value)
      Result.new(
        success: false,
        plugin_name: name,
        value: value
      )
    end

    def http_client
      @http_client ||= HttpClient.new
    end
  end
end
