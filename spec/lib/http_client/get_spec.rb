# frozen_string_literal: true

RSpec.describe HTTPClient::Get do
  subject(:execution) { described_class.new.call(url, limit) }

  include_context 'logger'

  let(:url) {}
  let(:limit) { 10 }

  context 'when url is not a valid string' do
    let(:url) { { url: 'not-a-host' } }

    include_examples 'HTTPClient Failure', 'URL must be a string'
  end

  context 'when limit is not an integer' do
    let(:url) { 'domain.tld' }
    let(:limit) { { limit: 'not-a-resource' } }

    include_examples 'HTTPClient Failure', 'Limit must be an integer'
  end

  context 'when url is empty' do
    let(:url) { ' ' }

    include_examples 'HTTPClient Failure', 'URL must not be empty'
  end

  context 'when too many redirects' do
    let(:url) { 'http://domain.tld' }
    let(:limit) { 0 }

    include_examples 'HTTPClient Failure', 'Too many HTTP redirects'
  end

  context 'when HTTPClient raises exceptions' do
    let(:url) { 'http://domain.tld' }

    include_examples 'HTTPClient Exceptions', :get, 'domain.tld'
  end

  context 'when resource is not found' do
    let(:url) { 'http://domain.tld' }

    before do
      stub_request(:get, url)
        .to_return(status: 404)
    end

    include_examples 'HTTPClient Failure', 'Server Error: 404 "Not Found"'
  end

  context 'when HTTP Bad Gateway' do
    let(:url) { 'http://domain.tld' }

    before do
      stub_request(:get, url)
        .to_return(status: 502)
    end

    include_examples 'HTTPClient Failure', 'Server Error: Bad Gateway'
  end

  context 'with valid arguments' do
    let(:url) { 'http://domain.tld' }

    before do
      stub_request(:get, url)
        .to_return(status: 200, body: 'content')
    end

    it 'is an instance of Net::HTTPOK' do
      klass = execution.value![:response]

      expect(klass).to be_an_instance_of(Net::HTTPOK)
    end

    include_examples 'HTTPClient Success', { code: 200, body: 'content' }
  end

  context 'with 301 redirect' do
    let(:url) { 'http://domain.tld' }

    before do
      stub_request(:get, /domain\.tld/)
        .to_return(
          {
            status: 301,
            headers: {
              'Location': 'https://domain.tld'
            }
          }, {
            status: 200,
            body: 'content'
          }
        )
    end

    it 'is an instance of Net::HTTPOK' do
      klass = execution.value![:response]

      expect(klass).to be_an_instance_of(Net::HTTPOK)
    end

    include_examples 'HTTPClient Success', { code: 200, body: 'content' }
  end
end
