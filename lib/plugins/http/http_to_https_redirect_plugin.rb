# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for redirect from HTTP to HTTPS
    class HTTPToHttpsRedirectPlugin < Base
      include Dry::Monads::Do.for(:call)

      def call(opts)
        values   = yield validate_opts(opts)
        values   = yield build_values(values)
        response = yield request_head(values[:url], '/')

        yield check_for_unexpected_status_code(values[:url], response[:code], 301)
        yield check_for_unexpected_location(values[:url], response[:location], "https://#{values[:domain]}/")

        Success(yield build_presentation(success: true))
      end

      def name
        'Redirect from HTTP to HTTPS'
      end

      protected

      def build_values(values)
        Success(
          domain: values[:domain],
          url: "http://#{values[:domain]}"
        )
      end
    end
  end
end
