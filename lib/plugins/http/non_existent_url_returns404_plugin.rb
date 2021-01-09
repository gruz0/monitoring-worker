# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for HTTP Status 404 for non-existent URL
    class NonExistentUrlReturns404Plugin < Base
      def call(opts)
        random = generate_random
        url    = "#{opts[:host]}/#{random}"

        response = http_client.head(opts[:host], "/#{random}")

        check_for_unexpected_status_code(url, response, 404)

        success
      rescue PluginError, HTTPClient::ClientError => e
        failure(e.message)
      end

      def name
        'HTTP Status 404 for non-existent URL'
      end

      protected

      def generate_random
        rand(36**36).to_s(36)
      end
    end
  end
end
