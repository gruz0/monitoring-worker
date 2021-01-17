# frozen_string_literal: true

require 'http_client/base'

class HTTPClient
  class Head < Base
    include Dry::Monads::Do.for(:call)

    class InputContract < Contracts::PluginContract
      params do
        required(:host).filled(Types::StrippedString)
        optional(:resource).filled(Types::StrippedString)
      end

      rule(:host) do
        key.failure('host must have a scheme') unless value.start_with?('http://', 'https://')
      end
    end

    def call(host, resource)
      values   = yield validate(host, resource)
      response = yield request_head(values[:host], values[:resource])

      Success(yield build_presentation(response))
    end

    protected

    def input_contract
      @input_contract ||= InputContract.new
    end

    def validate(host, resource)
      validate_contract(input_contract, host: host, resource: resource)
    end

    def request_head(host, resource)
      uri = URI.parse(host)

      response = start(uri) { |request| request.head(resource) }

      response.is_a?(Failure) ? response : Success(response)
    end

    def build_presentation(response)
      result = {
        response: response,
        code: response.code.to_i
      }

      case response
      when Net::HTTPRedirection
        return Failure('Response must have a Location in Headers') if response['Location'].to_s.empty?

        result[:location] = response['Location']
      end

      Success(result)
    end
  end
end
