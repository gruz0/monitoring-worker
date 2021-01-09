# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Content
    # Checks for page contains string
    class ContainsStringPlugin < Base
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def call(opts)
        host     = opts[:host]
        resource = opts.dig(:meta, :resource)
        url      = "#{host}/#{resource}"
        value    = opts.dig(:meta, :value)

        response = http_client.get(url)

        check_for_unexpected_status_code(url, response, 200)

        raise PluginError, format_error_message(prepare(url, value), false) unless response.body.include?(value)

        success
      rescue PluginError => e
        failure(e.message)
      rescue HTTPClient::ClientError => e
        failure(format_error_message(prepare(url, value), e.message))
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def name
        'Contains String'
      end

      private

      def prepare(url, value)
        "URL [#{url}] contains [#{value}]"
      end
    end
  end
end
