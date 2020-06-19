# frozen_string_literal: true

module Plugins
  module Http
    # Checks for redirect from HTTP to HTTPS
    class HttpToHttpsRedirectPlugin < Base
      def call(domain_name)
        response = request_head('http://' + domain_name, '/')

        check_for_unexpected_status_code(response, 301)
        check_for_unexpected_location(response, "https://#{domain_name}/")

        success
      rescue PluginError => e
        failure(e.message)
      end

      def name
        'Redirect from HTTP to HTTPS'
      end
    end
  end
end
