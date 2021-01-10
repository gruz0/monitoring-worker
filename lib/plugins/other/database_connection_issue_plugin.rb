# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Other
    # Checks for database connection error message
    class DatabaseConnectionIssuePlugin < Base
      def call(opts)
        host = opts[:host]

        response = http_client.get(host)

        if response.body.downcase.include?('access denied for user')
          raise PluginError, format_error_message(prepare(host), true)
        end

        success
      rescue PluginError => e
        failure(e.message)
      rescue HTTPClient::ClientError => e
        failure(format_error_message(prepare(host), e.message))
      end

      def name
        'Database Connection Issue'
      end

      private

      def prepare(url)
        "URL [#{url}] does not have database connection issue"
      end
    end
  end
end
