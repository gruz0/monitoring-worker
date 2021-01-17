# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for HTTP Status 200
    class HTTPStatus200Plugin < Base
      include Dry::Monads::Do.for(:call)

      def call(opts)
        values   = yield validate_opts(opts)
        response = yield request_get(values[:host])

        yield check_for_unexpected_status_code(values[:url], response[:code], 200)

        Success(yield build_presentation(success: true))
      end

      def name
        'HTTP Status 200'
      end
    end
  end
end
