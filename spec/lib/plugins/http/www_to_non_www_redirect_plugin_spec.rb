# frozen_string_literal: true

RSpec.describe Plugins::HTTP::WwwToNonWwwRedirectPlugin do
  subject(:execution) { described_class.new.call(opts) }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'Redirect from www to non-www'

  describe 'validate opts' do
    include_examples 'validate plugin opts'
  end

  context 'when HTTPClient raises exceptions' do
    include_examples 'HTTPClient Exceptions', :head, 'www.domain.tld'
  end

  context 'when HTTP Status is not expected' do
    include_examples 'Plugin Failure with Message',
                     'Expected URL [http://www.domain.tld/] returns [301] HTTP Status Code, got 200' do
      before do
        stub_request(:head, 'http://www.domain.tld/')
          .to_return(status: 200)
      end
    end
  end

  context 'when Location is not equal to expected' do
    include_examples 'Plugin Failure with Message',
                     'Expected URL [http://www.domain.tld/] returns ' \
                     'Location [http://domain.tld/] in Response Headers, got https://domain.tld/' do
      before do
        stub_request(:head, 'http://www.domain.tld/')
          .to_return(status: 301, headers: { 'Location': 'https://domain.tld/' })
      end
    end
  end

  context 'when request redirected to expected location' do
    include_examples 'Plugin success' do
      let(:domain) { 'domain.tld' }

      before do
        stub_request(:head, 'http://www.domain.tld/')
          .to_return(
            { status: 301, headers: { 'Location': 'http://domain.tld/' } },
            { status: 200, body: '' }
          )
      end
    end
  end
end
