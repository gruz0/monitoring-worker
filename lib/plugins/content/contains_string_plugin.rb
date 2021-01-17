# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Content
    # Checks for page contains string
    class ContainsStringPlugin < Base
      include Dry::Monads::Do.for(:call)

      def call(opts)
        values   = yield validate_opts(opts)
        meta     = yield validate_meta(opts)
        values   = yield build_values(values, meta)
        response = yield request_get(values[:url])

        yield check_for_unexpected_status_code(values[:url], response[:code], 200)
        yield contains_string?(response[:body], values[:expected])

        Success(yield build_presentation(success: true))
      end

      def name
        'Contains String'
      end

      protected

      def validate_meta(opts)
        meta = opts.fetch(:meta) { return Failure('Meta must be present') }
        return Failure('Meta must be a hash') unless meta.is_a?(Hash)

        resource = meta.fetch(:resource) { return Failure('Meta must have :resource') }
        return Failure('Resource must be a string') unless resource.is_a?(String)

        resource = resource.strip
        return Failure('Resource must not be empty') if resource.empty?

        return Failure('Resource must be started with leading slash') if resource[0] != '/'

        value = meta.fetch(:value) { return Failure('Meta must have :value') }
        return Failure('Value must be a string') unless value.is_a?(String)

        value = value.strip
        return Failure('Value must not be empty') if value.empty?

        Success(
          resource: resource,
          expected: value
        )
      end

      def build_values(values, meta)
        host     = values[:host]
        resource = meta[:resource]
        url      = "#{host}#{resource}"

        Success(
          resource: resource,
          url: url,
          expected: meta[:expected].downcase.force_encoding('UTF-8')
        )
      end

      def contains_string?(body, expected)
        content = body.downcase.force_encoding('UTF-8')

        return Success() if content.include?(expected)

        Failure('Expected content does not exist')
      end
    end
  end
end
