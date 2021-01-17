# frozen_string_literal: true

require_relative 'plugin_contract'

module Contracts
  class OptsContract < Contracts::PluginContract
    params do
      required(:scheme).filled(Types::String.enum('http', 'https'))
      required(:domain).filled(Types::StrippedString)
      required(:host).filled(Types::StrippedString)
    end

    rule(:domain) do
      key.failure('domain must not have a scheme') if value.start_with?('http://', 'https://')
    end

    rule(:host) do
      key.failure('host has invalid value') if value != "#{values[:scheme]}://#{values[:domain]}"
    end
  end
end
