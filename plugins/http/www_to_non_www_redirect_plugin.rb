# frozen_string_literal: true

module Plugins
  module Http
    # Checks for redirect from www to non-www
    class WwwToNonWwwRedirectPlugin < Base
      def call(opts)
        response = request_head(opts[:scheme] + '://www.' + opts[:domain], '/')

        check_for_unexpected_status_code(response, 301)
        check_for_unexpected_location(response, opts[:host] + '/')

        success
      rescue PluginError => e
        failure(e.message)
      end

      def name
        'Redirect from www to non-www'
      end
    end
  end
end
