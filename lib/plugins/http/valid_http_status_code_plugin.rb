# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for valid HTTP Status Code
    class ValidHTTPStatusCodePlugin < Base
      include Dry::Monads::Do.for(:call)

      class MetaContract < Contracts::PluginContract
        params do
          required(:meta).filled(:hash).schema do
            required(:enable).filled(:integer)
            required(:resource).filled(Types::StrippedString)
            required(:value).filled(:integer)
          end
        end

        rule(%i[meta resource]).validate(:leading_slash)
      end

      def call(input)
        opts     = yield validate_opts(input)
        meta     = yield validate_contract(meta_contract, input)
        values   = yield build_values(opts, meta)
        response = yield request_head(opts[:host], values[:resource])

        yield check_for_unexpected_status_code(response, values, values[:status_code])

        success
      end

      def name
        build_filename(__FILE__)
      end

      protected

      def meta_contract
        @meta_contract ||= MetaContract.new
      end

      def build_values(opts, meta)
        host     = opts[:host]
        resource = meta[:meta][:resource]
        url      = "#{host}#{resource}"

        Success(
          resource: resource,
          url: url,
          status_code: meta[:meta][:value]
        )
      end
    end
  end
end
