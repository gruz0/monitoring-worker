# frozen_string_literal: true

class HTTPClient
  class ClientError < StandardError; end

  include Import[http_client_head: 'http_client.head', http_client_get: 'http_client.get']

  def head(host, resource)
    http_client_head.call(host, resource)
  end

  def get(url, limit = 10)
    http_client_get.call(url, limit)
  end
end
