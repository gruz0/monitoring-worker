# frozen_string_literal: true

require 'net/http'

class HTTPClient
  include Import[:logger]

  class ClientError < StandardError; end

  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 10
  SSL_TIMEOUT = 5

  # rubocop:disable Metrics/AbcSize
  def head(domain, resource)
    raise ArgumentError, 'Domain must not be empty' if domain.to_s.strip.empty?
    raise ArgumentError, 'Resource must not be empty' if resource.to_s.strip.empty?

    domain   = domain.to_s.strip
    resource = resource.to_s.strip

    uri = URI.parse(domain)

    start(uri).head(resource)
  rescue StandardError => e
    logger.warn "HTTPClient#head StandardError: #{e.message}"

    raise ClientError, e.message
  end
  # rubocop:enable Metrics/AbcSize

  def get(url, limit = 10)
    raise ArgumentError, 'URL must not be empty' if url.to_s.strip.empty?
    raise ClientError, 'Too many HTTP redirects' if limit.zero?

    url = url.to_s.strip

    uri = URI.parse(url)

    get_response(uri, limit)
  rescue StandardError => e
    logger.warn "HTTPClient#get StandardError: #{e.message}"

    raise ClientError, e.message
  end

  private

  def get_response(uri, limit)
    response = start(uri).get(uri)

    case response
    when Net::HTTPSuccess
      response
    when Net::HTTPRedirection
      get(response['location'], limit - 1)
    else
      response.value
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def start(uri)
    Net::HTTP.start(uri.host, uri.port, options(uri))
  rescue SocketError => e
    logger.warn "HTTPClient#start SocketError: #{e.message}"

    raise ClientError, 'Socket Error: Domain does not resolve'
  rescue OpenSSL::SSL::SSLError => e
    logger.warn "HTTPClient#start SSLError: #{e.message}"

    raise ClientError, 'SSL Error: Invalid certificate'
  rescue Net::OpenTimeout => e
    logger.warn "HTTPClient#start Net::OpenTimeout: #{e.message}"

    raise ClientError, 'Network Error: Open timeout'
  rescue Timeout::Error => e
    logger.warn "HTTPClient#start Timeout::Error: #{e.message}"

    raise ClientError, 'Timeout Error: Reading from server'
  rescue Net::HTTPServerException => e
    logger.warn "HTTPClient#start Net::HTTPServerException: #{e.message}"

    raise ClientError, 'Server Error: 404 Not Found'
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def options(uri)
    {
      use_ssl: uri.port == 443,
      open_timeout: OPEN_TIMEOUT,
      read_timeout: READ_TIMEOUT,
      ssl_timeout: SSL_TIMEOUT
    }
  end
end
