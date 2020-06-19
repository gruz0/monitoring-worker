# frozen_string_literal: true

module Plugins
  module Http
    # Checks for redirect from www to non-www
    class WwwToNonWwwRedirectPlugin < Base
      def call(domain_name)
        response = request_head('http://www.' + domain_name, '/')

        check_for_unexpected_status_code(response, 301)
        check_for_unexpected_location(response, "http://#{domain_name}/")

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
