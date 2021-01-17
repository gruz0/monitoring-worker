# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for valid HTTP Status Code
    class ValidHTTPStatusCodePlugin < Base
      include Dry::Monads::Do.for(:call)

      def call(opts)
        values   = yield validate_opts(opts)
        meta     = yield validate_meta(opts)
        values   = yield build_values(values, meta)
        response = yield request_head(values[:host], values[:resource])

        yield check_for_unexpected_status_code(values[:url], response[:code], values[:status_code])

        Success(yield build_presentation(success: true))
      end

      def name
        'Valid HTTP Status Code'
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
        return Failure('Value must be an integer') unless value.is_a?(Integer)

        Success(
          resource: resource,
          status_code: value
        )
      end

      def build_values(values, meta)
        host     = values[:host]
        resource = meta[:resource]
        url      = "#{host}#{resource}"

        Success(
          host: host,
          resource: resource,
          url: url,
          status_code: meta[:status_code]
        )
      end
    end
  end
end
