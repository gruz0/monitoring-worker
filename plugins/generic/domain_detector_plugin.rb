# frozen_string_literal: true

module Plugins
  module Generic
    # Returns domain without www
    class DomainDetectorPlugin < Base
      def call(url)
        success(host_without_www(url))
      rescue StandardError => e
        failure(e.message)
      end

      def name
        'Domain without www'
      end

      private

      def host_without_www(url)
        uri = URI.parse(url)
        uri = URI.parse("http://#{url}") if uri.scheme.nil?
        host = uri.host.downcase
        host.start_with?('www.') ? host[4..] : host
      end
    end
  end
end
