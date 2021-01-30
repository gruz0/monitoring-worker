# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Generic
    # Returns scheme
    class SchemeDetectorPlugin < Base
      include Dry::Monads::Do.for(:call)

      class InputContract < Contracts::PluginContract
        params do
          required(:domain).filled(Types::StrippedString)
        end

        rule(:domain).validate(:domain_format)
      end

      def call(input)
        params = yield validate_contract(input_contract, input)
        uri    = yield build_uri(params[:domain])
        values = yield follow_redirect(build_values(uri))
        result = yield prepare_presentation(values[:url])

        Success(build_presentation(result))
      end

      def name
        build_filename(__FILE__)
      end

      protected

      def input_contract
        @input_contract ||= InputContract.new
      end

      def build_uri(url)
        url = valid_scheme?(url) ? url : "http://#{url}"
        uri = URI.parse(url)

        Success(uri)
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

        return failure(head.failure) if head.failure?

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
