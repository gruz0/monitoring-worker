# frozen_string_literal: true

require_relative 'types'

module Contracts
  class PluginContract < Dry::Validation::Contract
    register_macro(:domain_format) do
      uri = URI.parse(value)
      uri = URI.parse("http://#{value}") if uri.scheme.nil?

      raise URI::InvalidURIError unless uri.host
    rescue URI::InvalidURIError
      key.failure('domain is not valid')
    end

    register_macro(:leading_slash) do
      key.failure('resource must be started with a leading slash') if value[0] != '/'
    end
  end
end
