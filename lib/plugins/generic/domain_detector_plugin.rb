# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Generic
    # Returns domain without www
    class DomainDetectorPlugin < Base
      include Dry::Monads::Do.for(:call)

      def call(domain_name)
        domain = yield validate(domain_name)
        domain = yield remove_www(domain)
        result = yield build_presentation(domain: domain)

        Success(result)
      end

      def name
        'Domain Detector'
      end

      protected

      def validate(domain)
        return Failure('Domain must be a string') unless domain.is_a?(String)

        domain = domain.strip
        return Failure('Domain must not be empty') if domain.empty?

        Success(domain)
      end

      def remove_www(domain)
        uri = URI.parse(domain)
        uri = URI.parse("http://#{domain}") if uri.scheme.nil?

        raise URI::InvalidURIError unless uri.host

        host   = uri.host.downcase
        domain = host.start_with?('www.') ? host[4..] : host

        Success(domain)
      rescue URI::InvalidURIError
        Failure('Invalid domain name')
      end
    end
  end
end
