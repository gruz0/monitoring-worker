# frozen_string_literal: true

module Plugins
  module Generic
    # Returns scheme
    class SchemeDetectorPlugin < Base
      def call(domain)
        response = http_client.fetch("http://#{domain}")

        success(response.uri.scheme)
      rescue HttpClient::ClientError => e
        failure(e.message)
      end

      def name
        'Scheme Detector'
      end
    end
  end
end
