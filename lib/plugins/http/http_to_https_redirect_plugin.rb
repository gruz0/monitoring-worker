# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for redirect from HTTP to HTTPS
    class HTTPToHttpsRedirectPlugin < Base
      include Dry::Monads::Do.for(:call)

      def call(input)
        opts     = yield validate_opts(input)
        values   = yield build_values(opts)
        response = yield request_head(values[:url], '/')

        yield check_for_unexpected_status_code(response, values, 301)
        yield check_for_unexpected_location(response, values, "https://#{values[:domain]}/")

        success
      end

      def name
        build_filename(__FILE__)
      end

      protected

      def build_values(opts)
        Success(
          domain: opts[:domain],
          url: "http://#{opts[:domain]}/"
        )
      end
    end
  end
end
