# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for HTTP Status 200
    class HTTPStatus200Plugin < Base
      def call(opts)
        host = opts[:host]

        response = http_client.get(host)

        raise PluginError, format_error_message(prepare(host), response.code) if response.code != '200'

        success
      rescue PluginError => e
        failure(e.message)
      rescue HTTPClient::ClientError => e
        failure(format_error_message(prepare(host), e.message))
      end

      def name
        'HTTP Status 200'
      end

      private

      def prepare(url)
        "URL [#{url}] has [200] HTTP Status Code"
      end
    end
  end
end
