# frozen_string_literal: true

require 'http_client/base'

class HTTPClient
  class Head < Base
    include Dry::Monads::Do.for(:call)

    def call(host, resource)
      values   = yield validate(host, resource)
      response = yield request_head(values[:host], values[:resource])
      result   = yield build_presentation(response)

      Success(result)
    end

    protected

    def validate(host, resource)
      return Failure('Host must be a string') unless host.is_a?(String)
      return Failure('Resource must be a string') unless resource.is_a?(String)

      host     = host.to_s.strip
      resource = resource.to_s.strip

      return Failure('Host must not be empty') if host.empty?
      return Failure('Host must have a scheme') unless valid_scheme?(host)
      return Failure('Resource must not be empty') if resource.empty?

      Success(host: host, resource: resource)
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

    def valid_scheme?(host)
      host.start_with?('http://', 'https://')
    end
  end
end
