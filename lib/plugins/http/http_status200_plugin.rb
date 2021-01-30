# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for HTTP Status 200
    class HTTPStatus200Plugin < Base
      include Dry::Monads::Do.for(:call)

      def call(input)
        opts     = yield validate_opts(input)
        values   = yield build_values(opts)
        response = yield request_head(opts[:host], '/')

        yield check_for_unexpected_status_code(response, values, 200)

        success
      end

      def name
        build_filename(__FILE__)
      end

      protected

      def build_values(opts)
        Success(url: "#{opts[:host]}/")
      end
    end
  end
end
