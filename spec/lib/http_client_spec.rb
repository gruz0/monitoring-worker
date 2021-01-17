# frozen_string_literal: true

RSpec.describe HTTPClient do
  subject(:client) { described_class.new }

  describe '#head' do
    subject(:execution) { client.head(host, resource) }

    let(:host) { 'http://domain.tld' }
    let(:resource) { '/' }
    let(:url) { "#{host}#{resource}" }

    context 'when host should not be redirected' do
      before do
        stub_request(:head, url)
          .to_return(status: 200)
      end

      include_examples 'HTTPClient Success', { code: 200 }
    end

    context 'when host should be redirected' do
      before do
        stub_request(:head, url)
          .to_return(status: 301, body: '', headers: { 'Location' => 'https://domain.tld' })
      end

      it 'is an instance of Net::HTTPMovedPermanently' do
        klass = execution.value![:response]

        expect(klass).to be_an_instance_of(Net::HTTPMovedPermanently)
      end

      include_examples 'HTTPClient Success', { code: 301, location: 'https://domain.tld' }
    end
  end

  describe '#get' do
    subject(:execution) { client.get(url, limit) }

    let(:url) { 'http://domain.tld' }
    let(:limit) { 10 }

    before do
      stub_request(:get, url)
        .to_return(status: 200, body: 'content')
    end

    include_examples 'HTTPClient Success', { code: 200, body: 'content' }
  end
end
