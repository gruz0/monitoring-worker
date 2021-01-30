# frozen_string_literal: true

RSpec.describe Plugins::Generic::SchemeDetectorPlugin do
  subject(:execution) { described_class.new.call(input) }

  include_context 'set plugin name', 'scheme_detector'

  let(:input) { {} }

  shared_examples 'SchemeDetectorPlugin Success' do |scheme|
    let(:attrs) do
      {
        plugin_namespace: plugin_namespace(described_class),
        plugin_name: 'scheme_detector',
        scheme: scheme
      }
    end

    it 'is Success' do
      expect(execution).to eq(Success(attrs))
    end
  end

  context 'when domain is missing' do
    before { input.delete(:domain) }

    include_examples 'Plugin Failure', 'domain is missing'
  end

  context 'when domain is nil' do
    before { input[:domain] = nil }

    include_examples 'Plugin Failure', 'domain must be filled'
  end

  context 'when domain is not a string' do
    before { input[:domain] = false }

    include_examples 'Plugin Failure', 'domain must be a string'
  end

  context 'when domain is empty' do
    before { input[:domain] = ' ' }

    include_examples 'Plugin Failure', 'domain must be filled'
  end

  context 'when domain could not be parsed' do
    before { input[:domain] = '"' }

    include_examples 'Plugin Failure', 'domain is not valid'
  end

  context 'without scheme and resource' do
    before do
      input[:domain] = 'domain.tld'

      stub_request(:head, 'http://domain.tld/')
        .to_return(status: 200)
    end

    include_examples 'SchemeDetectorPlugin Success', 'http'
  end

  context 'without scheme' do
    before do
      input[:domain] = 'domain.tld/123'

      stub_request(:head, 'http://domain.tld/123')
        .to_return(status: 200)
    end

    include_examples 'SchemeDetectorPlugin Success', 'http'
  end

  context 'without resource' do
    before do
      input[:domain] = 'http://domain.tld'

      stub_request(:head, 'http://domain.tld')
        .to_return(status: 200)
    end

    include_examples 'SchemeDetectorPlugin Success', 'http'
  end

  context 'with redirect' do
    before do
      input[:domain] = 'domain.tld'

      stub_request(:head, /domain.tld/)
        .to_return(
          { status: 301, headers: { 'Location': 'https://domain.tld' } },
          { status: 200 }
        )
    end

    include_examples 'SchemeDetectorPlugin Success', 'https'
  end

  context 'with multiple 301 redirects' do
    before do
      input[:domain] = 'domain.tld'

      stub_request(:head, /domain.tld/)
        .to_return(
          { status: 301, headers: { 'Location': 'https://domain.tld' } },
          { status: 301, headers: { 'Location': 'https://www.domain.tld' } },
          { status: 301, headers: { 'Location': 'https://www1.domain.tld' } },
          { status: 200 }
        )
    end

    include_examples 'SchemeDetectorPlugin Success', 'https'
  end

  context 'with multiple different redirects' do
    before do
      input[:domain] = 'domain.tld'

      stub_request(:head, /domain.tld/)
        .to_return(
          { status: 301, headers: { 'Location': 'https://domain.tld' } },
          { status: 302, headers: { 'Location': 'https://domain.tld/auth/sign_in' } },
          { status: 200 }
        )
    end

    include_examples 'SchemeDetectorPlugin Success', 'https'
  end

  context 'when HTTPClient raises exceptions' do
    before do
      input[:domain] = 'domain.tld'
    end

    context 'when domain could not be resolved' do
      before do
        stub_request(:head, 'domain.tld')
          .to_raise(SocketError)
      end

      include_examples 'Plugin Failure', 'Socket Error: Domain does not resolve'
    end

    context 'when SSL certificate is not valid' do
      before do
        stub_request(:head, 'domain.tld')
          .to_raise(OpenSSL::SSL::SSLError)
      end

      include_examples 'Plugin Failure', 'SSL Error: Invalid certificate'
    end

    context 'when open connection timed out' do
      before do
        stub_request(:head, 'domain.tld')
          .to_raise(Net::OpenTimeout)
      end

      include_examples 'Plugin Failure', 'Network Error: Open timeout'
    end

    context 'when read connection timed out' do
      before do
        stub_request(:head, 'domain.tld')
          .to_raise(Timeout::Error)
      end

      include_examples 'Plugin Failure', 'Timeout Error: Reading from server'
    end
  end
end
