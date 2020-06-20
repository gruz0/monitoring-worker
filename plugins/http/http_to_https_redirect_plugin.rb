# frozen_string_literal: true

module Plugins
  module Http
    # Checks for redirect from HTTP to HTTPS
    class HttpToHttpsRedirectPlugin < Base
      def call(opts)
        response = request_head('http://' + opts[:domain], '/')

        check_for_unexpected_status_code(response, 301)
        check_for_unexpected_location(response, "https://#{opts[:domain]}/")

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
