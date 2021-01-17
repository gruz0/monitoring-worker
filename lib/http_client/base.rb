# frozen_string_literal: true

require 'net/http'
require 'dry/monads/all'

class HTTPClient
  class Base
    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 10
    SSL_TIMEOUT = 5

    include Import[:logger]
    include Dry::Monads[:result]

    private

    def start(uri, &block)
      Net::HTTP.start(uri.host, uri.port, options(uri), &block)
    rescue SocketError
      Failure('Socket Error: Domain does not resolve')
    rescue OpenSSL::SSL::SSLError
      Failure('SSL Error: Invalid certificate')
    rescue Net::OpenTimeout
      Failure('Network Error: Open timeout')
    rescue Timeout::Error
      Failure('Timeout Error: Reading from server')
    end

    protected

    def options(uri)
      {
        use_ssl: uri.port == 443,
        open_timeout: OPEN_TIMEOUT,
        read_timeout: READ_TIMEOUT,
        ssl_timeout: SSL_TIMEOUT
      }
    end
  end
end
