# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module HTTP
    # Checks for redirect from www to non-www
    class WwwToNonWwwRedirectPlugin < Base
      def call(opts)
        url = "#{opts[:scheme]}://www.#{opts[:domain]}"

        response = http_client.head(url, '/')

        check_for_unexpected_status_code(url, response, 301)
        check_for_unexpected_location(url, response, "#{opts[:host]}/")

        success
      rescue PluginError => e
        failure(e.message)
      rescue HTTPClient::ClientError => e
        failure(format_error_message(prepare(url), e.message))
      end

      def name
        'Redirect from www to non-www'
      end

      private

      def prepare(url)
        "URL [#{url}] has valid redirect from www to non-www"
      end
    end
  end
end
