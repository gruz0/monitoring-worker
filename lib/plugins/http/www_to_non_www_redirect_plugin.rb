# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for redirect from www to non-www
    class WwwToNonWwwRedirectPlugin < Base
      include Dry::Monads::Do.for(:call)

      def call(input)
        opts     = yield validate_opts(input)
        values   = yield build_values(opts)
        response = yield request_head(values[:url], '/')

        yield check_for_unexpected_status_code(response, values, 301)
        yield check_for_unexpected_location(response, values, "#{opts[:host]}/")

        success
      end

      def name
        'Redirect from www to non-www'
      end

      protected

      def build_values(values)
        Success(url: "#{values[:scheme]}://www.#{values[:domain]}/")
      end
    end
  end
end
