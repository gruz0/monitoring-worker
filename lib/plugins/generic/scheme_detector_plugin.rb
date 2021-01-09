# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Generic
    # Returns scheme
    class SchemeDetectorPlugin < Base
      def call(domain)
        raise ArgumentError, 'Domain must not be empty' if domain.to_s.strip.empty?

        response = http_client.get("http://#{domain}")

        success(response.uri.scheme)
      rescue HTTPClient::ClientError => e
        failure(e.message)
      rescue StandardError => e
        failure(e.message)
      end

      def name
        'Scheme Detector'
      end
    end
  end
end
