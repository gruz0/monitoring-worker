# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Content
    # Checks for page does not contain string
    class DoesNotContainStringPlugin < Base
      include Dry::Monads::Do.for(:call)

      class MetaContract < Contracts::PluginContract
        params do
          required(:meta).filled(:hash).schema do
            required(:enable).filled(:integer)
            required(:resource).filled(Types::StrippedString)
            required(:value).filled(Types::StrippedString)
          end
        end

        rule(%i[meta resource]).validate(:leading_slash)
      end

      def call(input)
        opts     = yield validate_opts(input)
        meta     = yield validate_contract(meta_contract, input)
        values   = yield build_values(opts, meta)
        response = yield request_get(values[:url])

        yield check_for_unexpected_status_code(response, values, 200)
        yield does_not_contain_string?(response, values)

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
          not_expected: meta[:meta][:value].to_s.downcase.force_encoding('UTF-8')
        )
      end

      def does_not_contain_string?(response, values)
        body         = response[:body]
        not_expected = values[:not_expected]
        content      = body.downcase.force_encoding('UTF-8')

        return Success() unless content.include?(not_expected)

        failure('Expected content exists')
      end
    end
  end
end
