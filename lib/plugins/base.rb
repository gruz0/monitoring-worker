# frozen_string_literal: true

require 'dry/validation'
require 'dry/monads'
require 'dry/monads/do'
require 'contracts/plugin_contract'

Dry::Validation.load_extensions(:monads)

module Plugins
  class PluginError < StandardError; end

  # Base class
  class Base
    include Import[:logger, :http_client, 'utils.contract_validator', 'contracts.opts_contract']
    include Dry::Monads[:result]

    def call(_)
      raise NotImplementedError
    end

    def name
      raise NotImplementedError
    end

    private

    def validate_opts(input)
      validate_contract(opts_contract, input)
    end

    def validate_contract(contract, input)
      contract_validator.call(contract, input)
    end

    def success
      Success(build_presentation(success: true))
    end

    def request_head(host, resource)
      http_client.head(host, resource)
    end

    def request_get(url)
      http_client.get(url)
    end

    def check_for_unexpected_status_code(response, values, expected)
      url  = values[:url]
      code = response[:code]

      return Success(code) if code == expected

      Failure(format_error_message("URL [#{url}] returns [#{expected}] HTTP Status Code", code))
    end

    def check_for_unexpected_location(response, values, expected)
      url      = values[:url]
      location = response[:location]

      message = "URL [#{url}] returns Location [#{expected}] in Response Headers"

      return Failure(format_error_message(message, 'empty')) if location.empty?

      return Success(location) if location == expected

      Failure(format_error_message(message, location))
    end

    def valid_scheme?(url)
      url.start_with?('http://', 'https://')
    end

    def build_presentation(response)
      plugin_meta.merge(response)
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
