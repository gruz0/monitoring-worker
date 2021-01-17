# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for HTTP Status 404 for non-existent URL
    class NonExistentUrlReturns404Plugin < Base
      include Dry::Monads::Do.for(:call)

      def call(opts)
        values   = yield validate_opts(opts)
        values   = yield build_values(values)
        response = yield request_head(values[:host], values[:resource])

        yield check_for_unexpected_status_code(values[:url], response[:code], 404)

        Success(yield build_presentation(success: true))
      end

      def name
        'HTTP Status 404 for non-existent URL'
      end

      protected

      def build_values(values)
        host   = values[:host]
        random = generate_random

        Success(
          host: host,
          resource: "/#{random}",
          url: "#{host}/#{random}"
        )
      end

      def generate_random
        rand(36**36).to_s(36)
      end
    end
  end
end
