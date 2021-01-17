# frozen_string_literal: true

require 'http_client/base'

class HTTPClient
  class Get < Base
    include Dry::Monads::Do.for(:call)

    class InputContract < Contracts::PluginContract
      params do
        required(:url).filled(Types::StrippedString)
        optional(:limit).value(:integer)
      end

      rule(:limit) do
        key.failure('too many HTTP redirects') if value.zero?
      end
    end

    def call(url, limit = 10)
      values   = yield validate(url, limit)
      response = yield request_get(values[:url], values[:limit])

      Success(yield build_presentation(response))
    end

    protected

    def input_contract
      @input_contract ||= InputContract.new
    end

    def validate(url, limit)
      validate_contract(input_contract, url: url, limit: limit)
    end

    def request_get(url, limit)
      uri = URI.parse(url)

      response = start(uri) { |request| request.get(uri) }

      return response if response.is_a?(Failure)

      check_response!(response, limit)
    rescue ClientError => e
      logger.warn "HTTPClient::Get#request_get #{e.message}"

      Failure(e.message)
    end

    def check_response!(response, limit)
      case response
      when Net::HTTPSuccess then Success(response)
      when Net::HTTPRedirection then request_get(response['Location'], limit - 1)
      when Net::HTTPNotFound then raise ClientError, 'Server Error: 404 "Not Found"'
      when Net::HTTPBadGateway then raise ClientError, 'Server Error: Bad Gateway'
      else response.value!
      end
    end

    def build_presentation(response)
      Success(
        response: response,
        code: response.code.to_i,
        body: response.body
      )
    end
  end
end
