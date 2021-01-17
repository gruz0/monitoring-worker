# frozen_string_literal: true

RSpec.describe Plugins::Generic::SchemeDetectorPlugin do
  subject(:execution) { described_class.new.call(url) }

  let(:url) {}

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

  context 'when url is nil' do
    let(:url) {}

    it { is_expected.to eq(Failure('URL must be a string')) }
  end

  context 'when url is empty' do
    let(:url) { ' ' }

    it { is_expected.to eq(Failure('URL must not be empty')) }
  end

  context 'when url could not be parsed' do
    let(:url) { '"' }

    it { is_expected.to eq(Failure('Invalid URL')) }
  end

  context 'without scheme and resource' do
    let(:url) { 'domain.tld' }

    before do
      stub_request(:head, "http://#{url}/")
        .to_return(status: 200)
    end

    include_examples 'SchemeDetectorPlugin Success', 'http'
  end

  context 'without scheme' do
    let(:url) { 'domain.tld/123' }

    before do
      stub_request(:head, "http://#{url}")
        .to_return(status: 200)
    end

    include_examples 'SchemeDetectorPlugin Success', 'http'
  end

  context 'without resource' do
    let(:url) { 'http://domain.tld' }

    before do
      stub_request(:head, url)
        .to_return(status: 200)
    end

    include_examples 'SchemeDetectorPlugin Success', 'http'
  end

  context 'with redirect' do
    let(:url) { 'domain.tld' }

    before do
      stub_request(:head, url)
        .to_return(status: 301, headers: { 'Location': "https://#{url}" })

      stub_request(:head, "https://#{url}")
        .to_return(status: 200)
    end

    include_examples 'SchemeDetectorPlugin Success', 'https'
  end

  context 'with multiple 301 redirects' do
    let(:url) { 'domain.tld' }

    before do
      stub_request(:head, "http://#{url}")
        .to_return(status: 301, headers: { 'Location': "https://#{url}" })

      stub_request(:head, "https://#{url}")
        .to_return(status: 301, headers: { 'Location': "https://www.#{url}" })

      stub_request(:head, "https://www.#{url}")
        .to_return(status: 301, headers: { 'Location': "https://www1.#{url}" })

      stub_request(:head, "https://www1.#{url}")
        .to_return(status: 200)
    end

    include_examples 'SchemeDetectorPlugin Success', 'https'
  end

  context 'with multiple different redirects' do
    let(:url) { 'domain.tld' }

    before do
      stub_request(:head, "http://#{url}")
        .to_return(status: 301, headers: { 'Location': "https://#{url}" })

      stub_request(:head, "https://#{url}")
        .to_return(status: 302, headers: { 'Location': "https://#{url}/auth/sign_in" })

      stub_request(:head, "https://#{url}/auth/sign_in")
        .to_return(status: 200)
    end

    include_examples 'SchemeDetectorPlugin Success', 'https'
  end

  context 'when HTTPClient raises exceptions' do
    let(:url) { 'domain.tld' }

    include_examples 'HTTPClient Exceptions', :head, 'domain.tld'
  end
end
