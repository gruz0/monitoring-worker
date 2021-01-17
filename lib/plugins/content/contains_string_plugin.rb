# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Content
    # Checks for page contains string
    class ContainsStringPlugin < Base
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
        yield contains_string?(response, values)

        success
      end

      def name
        'Contains String'
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
          expected: meta[:meta][:value].to_s.downcase.force_encoding('UTF-8')
        )
      end

      def contains_string?(response, values)
        body     = response[:body]
        expected = values[:expected]
        content  = body.downcase.force_encoding('UTF-8')

        return Success() if content.include?(expected)

        Failure('Expected content does not exist')
      end
    end
  end
end
