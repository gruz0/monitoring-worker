# frozen_string_literal: true

module Plugins
  module HTTP
    # Checks for redirect from HTTP to HTTPS
    class HTTPToHttpsRedirectPlugin < Base
      def call(opts)
        domain = opts[:domain]
        url    = "http://#{domain}"

        response = http_client.head(url, '/')

        check_for_unexpected_status_code(url, response, 301)
        check_for_unexpected_location(url, response, "https://#{domain}/")

        success
      rescue PluginError, HTTPClient::ClientError => e
        failure(e.message)
      end

      def name
        'Redirect from HTTP to HTTPS'
      end
    end
  end
end
