# frozen_string_literal: true

require 'plugins/base'

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
      rescue PluginError => e
        failure(e.message)
      rescue HTTPClient::ClientError => e
        failure(format_error_message(prepare(url), e.message))
      end

      def name
        'Redirect from HTTP to HTTPS'
      end

      private

      def prepare(host)
        "host [#{host}] has valid redirect from HTTP to HTTPS"
      end
    end
  end
end
