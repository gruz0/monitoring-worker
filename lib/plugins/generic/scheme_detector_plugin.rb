# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Generic
    # Returns scheme
    class SchemeDetectorPlugin < Base
      include Dry::Monads::Do.for(:call)

      def call(url)
        url    = yield validate(url)
        uri    = yield build_uri(url)
        values = build_values(uri)
        values = yield follow_redirect(values)
        view   = yield prepare_presentation(values[:url])
        result = yield build_presentation(view)

        Success(result)
      end

      def name
        'Scheme Detector'
      end

      protected

      def validate(url)
        return Failure('URL must be a string') unless url.is_a?(String)

        url = url.strip
        return Failure('URL must not be empty') if url.empty?

        Success(url)
      end

      def build_uri(url)
        url = valid_scheme?(url) ? url : "http://#{url}"
        uri = URI.parse(url)

        Success(uri)
      rescue URI::InvalidURIError
        Failure('Invalid URL')
      end

      def build_values(uri)
        host        = "#{uri.scheme}://#{uri.host}"
        request_uri = uri.request_uri

        {
          host: host,
          request_uri: request_uri,
          url: "#{host}#{request_uri}"
        }
      end

      def follow_redirect(values)
        head = request_head(values[:host], values[:request_uri])

        return head if head.failure?

        return Success(values) unless redirect?(head.value![:response])

        uri    = URI.parse(head.value![:location])
        values = build_values(uri)

        follow_redirect(values)
      end

      def redirect?(response)
        response.is_a?(Net::HTTPRedirection)
      end

      def prepare_presentation(new_url)
        uri = URI.parse(new_url)

        Success(scheme: uri.scheme)
      end
    end
  end
end
