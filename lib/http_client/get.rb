# frozen_string_literal: true

require 'http_client/base'

class HTTPClient
  class Get < Base
    include Dry::Monads::Do.for(:call)

    def call(url, limit = 10)
      values   = yield validate(url, limit)
      response = yield request_get(values[:url], values[:limit])
      result   = yield build_presentation(response)

      Success(result)
    end

    protected

    def validate(url, limit)
      return Failure('URL must be a string') unless url.is_a?(String)
      return Failure('Limit must be an integer') unless limit.is_a?(Integer)

      url   = url.to_s.strip
      limit = limit.to_i

      return Failure('URL must not be empty') if url.empty?
      return Failure('Too many HTTP redirects') if limit.zero?

      Success(
        url: url,
        limit: limit
      )
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
