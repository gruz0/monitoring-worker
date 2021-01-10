# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Generic
    # Returns scheme
    class SchemeDetectorPlugin < Base
      def call(domain)
        domain = domain.to_s.strip

        response = http_client.get("http://#{domain}")

        success(response.uri.scheme)
      rescue HTTPClient::ClientError => e
        failure(format_error_message(prepare(domain), e.message))
      rescue StandardError => e
        failure(e.message)
      end

      def name
        'Scheme Detector'
      end

      private

      def prepare(domain)
        "domain [#{domain}] has valid scheme"
      end
    end
  end
end
