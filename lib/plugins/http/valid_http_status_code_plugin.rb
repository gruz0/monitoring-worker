# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for valid HTTP Status Code
    class ValidHTTPStatusCodePlugin < Base
      # rubocop:disable Metrics/MethodLength
      def call(opts)
        host        = opts[:host]
        resource    = opts.dig(:meta, :resource)
        status_code = opts.dig(:meta, :value)

        url = "#{host}/#{resource}"

        response = http_client.head(host, resource)

        check_for_unexpected_status_code(url, response, status_code)

        success
      rescue PluginError => e
        failure(e.message)
      rescue HTTPClient::ClientError => e
        failure(format_error_message(prepare(url, status_code), e.message))
      end
      # rubocop:enable Metrics/MethodLength

      def name
        'Valid HTTP Status Code'
      end

      private

      def prepare(url, value)
        "URL [#{url}] has [#{value}] HTTP Status Code"
      end
    end
  end
end
