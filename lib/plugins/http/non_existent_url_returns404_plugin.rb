# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for HTTP Status 404 for non-existent URL
    class NonExistentUrlReturns404Plugin < Base
      include Dry::Monads::Do.for(:call)

      def call(input)
        opts     = yield validate_opts(input)
        values   = yield build_values(opts)
        response = yield request_head(opts[:host], values[:resource])

        yield check_for_unexpected_status_code(response, values, 404)

        success
      end

      def name
        build_filename(__FILE__)
      end

      protected

      def build_values(opts)
        random = generate_random

        Success(
          resource: "/#{random}",
          url: "#{opts[:host]}/#{random}"
        )
      end

      def generate_random
        rand(36**36).to_s(36)
      end
    end
  end
end
