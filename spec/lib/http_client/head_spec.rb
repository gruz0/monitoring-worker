# frozen_string_literal: true

RSpec.describe HTTPClient::Head do
  subject(:execution) { described_class.new.call(host, resource) }

  include_context 'logger'

  let(:host) {}
  let(:resource) {}

  context 'when host is not a valid string' do
    let(:host) { { url: 'not-a-host' } }
    let(:resource) { '/' }

    include_examples 'HTTPClient Failure', 'Host must be a string'
  end

  context 'when resource is not a valid string' do
    let(:host) { 'domain.tld' }
    let(:resource) { { resource: 'not-a-resource' } }

    include_examples 'HTTPClient Failure', 'Resource must be a string'
  end

  context 'when host is empty' do
    let(:host) { ' ' }
    let(:resource) { '/' }

    include_examples 'HTTPClient Failure', 'Host must not be empty'
  end

  context 'when host does not have valid scheme' do
    let(:host) { 'domain.tld' }
    let(:resource) { '/' }

    include_examples 'HTTPClient Failure', 'Host must have a scheme'
  end

  context 'when resource is empty' do
    let(:host) { 'http://domain.tld' }
    let(:resource) { ' ' }

    include_examples 'HTTPClient Failure', 'Resource must not be empty'
  end

  context 'when HTTPClient raises exceptions' do
    let(:host) { 'https://domain.tld' }
    let(:resource) { '/' }
    let(:url) { "#{host}#{resource}" }

    include_examples 'HTTPClient Exceptions', :head, 'https://domain.tld'
  end

  context 'when resource is not found' do
    let(:host) { 'https://domain.tld' }
    let(:resource) { '/' }
    let(:url) { "#{host}#{resource}" }

    before do
      stub_request(:head, url)
        .to_return(status: 404)
    end

    it 'is an instance of Net::HTTPNotFound' do
      klass = execution.value![:response]

      expect(klass).to be_an_instance_of(Net::HTTPNotFound)
    end

    include_examples 'HTTPClient Success', { code: 404 }
  end

  context 'when HTTP Bad Gateway' do
    let(:host) { 'https://domain.tld' }
    let(:resource) { '/' }
    let(:url) { "#{host}#{resource}" }

    before do
      stub_request(:head, url)
        .to_return(status: 502)
    end

    it 'is an instance of Net::HTTPBadGateway' do
      klass = execution.value![:response]

      expect(klass).to be_an_instance_of(Net::HTTPBadGateway)
    end

    include_examples 'HTTPClient Success', { code: 502 }
  end

  context 'when host should not be redirected' do
    let(:host) { 'http://domain.tld' }
    let(:resource) { '/' }
    let(:url) { "#{host}#{resource}" }

    before do
      stub_request(:head, url)
        .to_return(status: 200)
    end

    it 'is an instance of Net::HTTPOK' do
      klass = execution.value![:response]

      expect(klass).to be_an_instance_of(Net::HTTPOK)
    end

    include_examples 'HTTPClient Success', { code: 200 }
  end

  context 'when host should be redirected' do
    let(:host) { 'http://domain.tld' }
    let(:resource) { '/' }
    let(:url) { "#{host}#{resource}" }

    before do
      stub_request(:head, url)
        .to_return(status: 301, headers: { 'Location' => 'https://domain.tld' })
    end

    it 'is an instance of Net::HTTPMovedPermanently' do
      klass = execution.value![:response]

      expect(klass).to be_an_instance_of(Net::HTTPMovedPermanently)
    end

    include_examples 'HTTPClient Success', { code: 301, location: 'https://domain.tld' }
  end
end
