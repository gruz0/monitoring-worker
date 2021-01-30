# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Generic
    # Returns domain without www
    class DomainDetectorPlugin < Base
      include Dry::Monads::Do.for(:call)

      class InputContract < Contracts::PluginContract
        params do
          required(:domain).filled(Types::StrippedString)
        end

        rule(:domain).validate(:domain_format)
      end

      def call(input)
        params = yield validate_contract(input_contract, input)
        values = yield build_values(params)

        Success(build_presentation(values))
      end

      def name
        build_filename(__FILE__)
      end

      protected

      def input_contract
        @input_contract ||= InputContract.new
      end

      def build_values(input)
        Success(domain: clean_domain(input[:domain]))
      end

      def clean_domain(domain)
        uri  = URI.parse(domain)
        uri  = URI.parse("http://#{domain}") if uri.scheme.nil?
        host = uri.host.downcase

        host.start_with?('www.') ? host[4..] : host
      end
    end
  end
end
