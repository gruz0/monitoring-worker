# frozen_string_literal: true

module Plugins
  module Http
    # Checks for HTTP Status 200
    class HttpStatus200Plugin < Base
      def call(opts)
        check_for_http_200_following_redirects(opts[:host])

        success
      rescue PluginError, HttpClient::ClientError => e
        failure(e.message)
      end

      def name
        'HTTP Status 200'
      end

      protected

      def check_for_http_200_following_redirects(url)
        response = http_client.fetch(url)

        raise PluginError, "Expected 200 HTTP Status, got: #{response.code}" if response.code != '200'
      end
    end
  end
end