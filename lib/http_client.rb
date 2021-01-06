# frozen_string_literal: true

class HttpClient
  class ClientError < StandardError; end

  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 10
  SSL_TIMEOUT = 5

  def head(domain_name, resource)
    uri = URI.parse(domain_name)

    start(uri).head(resource)
  rescue Net::OpenTimeout
    raise ClientError, 'Open timeout'
  rescue Timeout::Error
    raise ClientError, 'Timeout reading from server'
  end

  def fetch(url, limit = 10)
    raise ClientError, 'Too many HTTP redirects' if limit.zero?

    uri = URI.parse(url)

    get_response(uri, limit)
  rescue Net::OpenTimeout
    raise ClientError, 'Open timeout'
  rescue Timeout::Error
    raise ClientError, 'Timeout reading from server'
  end

  private

  def get_response(uri, limit)
    response = start(uri).get(uri)

    case response
    when Net::HTTPSuccess
      response
    when Net::HTTPRedirection
      fetch(response['location'], limit - 1)
    else
      response.value
    end
  end

  def start(uri)
    Net::HTTP.start(uri.host, uri.port, options(uri))
  rescue Net::OpenTimeout
    raise ClientError, 'Open timeout'
  rescue Timeout::Error
    raise ClientError, 'Timeout connecting to server'
  rescue SocketError
    raise ClientError, 'Unknown server'
  rescue StandardError => e
    raise ClientError, "Unhandled exception: #{e.message}"
  end

  def options(uri)
    {
      use_ssl: uri.port == 443,
      open_timeout: OPEN_TIMEOUT,
      read_timeout: READ_TIMEOUT,
      ssl_timeout: SSL_TIMEOUT
    }
  end
end
