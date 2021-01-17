# frozen_string_literal: true

RSpec.describe Plugins::Generic::SchemeDetectorPlugin do
  subject(:execution) { described_class.new.call(input) }

  let(:input) { {} }

  shared_examples 'SchemeDetectorPlugin Success' do |scheme|
    let(:attrs) do
      {
        plugin_class: described_class.name,
        plugin_name: 'Scheme Detector',
        scheme: scheme
      }
    end

    it 'is Success' do
      expect(execution).to eq(Success(attrs))
    end
  end

  context 'when domain is missing' do
    before { input.delete(:domain) }

    include_examples 'Plugin Failure', { domain: ['domain is missing'] }
  end

  context 'when domain is nil' do
    before { input[:domain] = nil }

    include_examples 'Plugin Failure', { domain: ['domain must be filled'] }
  end

  context 'when domain is not a string' do
    before { input[:domain] = false }

    include_examples 'Plugin Failure', { domain: ['domain must be a string'] }
  end

  context 'when domain is empty' do
    before { input[:domain] = ' ' }

    include_examples 'Plugin Failure', { domain: ['domain must be filled'] }
  end

  context 'when domain could not be parsed' do
    before { input[:domain] = '"' }

    include_examples 'Plugin Failure', { domain: ['domain is not valid'] }
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

    include_examples 'HTTPClient Exceptions', :head, 'domain.tld'
  end
end
