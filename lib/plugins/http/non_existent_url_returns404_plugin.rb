# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for HTTP Status 404 for non-existent URL
    class NonExistentUrlReturns404Plugin < Base
      def call(opts)
        random = generate_random
        host   = opts[:host]
        url    = "#{host}/#{random}"

        response = http_client.head(host, "/#{random}")

        check_for_unexpected_status_code(url, response, 404)

        success
      rescue PluginError => e
        failure(e.message)
      rescue HTTPClient::ClientError => e
        failure(format_error_message(prepare(url), e.message))
      end

      def name
        'HTTP Status 404 for non-existent URL'
      end

      protected

      def generate_random
        rand(36**36).to_s(36)
      end

      private

      def prepare(url)
        "URL [#{url}] returns [404] HTTP Status Code"
      end
    end
  end
end
