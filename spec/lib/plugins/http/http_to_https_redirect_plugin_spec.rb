# frozen_string_literal: true

RSpec.describe Plugins::HTTP::HTTPToHttpsRedirectPlugin do
  subject(:execution) { described_class.new.call(opts) }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'http_to_https_redirect'

  describe 'validate opts' do
    include_examples 'validate plugin opts'
  end

  context 'when HTTPClient raises exceptions' do
    include_examples 'HTTPClient Exceptions', :head, 'domain.tld'
  end

  context 'when HTTP Status is not expected' do
    include_examples 'Plugin Failure with Message',
                     'Expected URL [http://domain.tld/] returns [301] HTTP Status Code, got 200' do
      before do
        stub_request(:head, domain)
          .to_return(status: 200)
      end
    end
  end

  context 'when Location is not equal to expected' do
    include_examples 'Plugin Failure with Message',
                     'Expected URL [http://domain.tld/] returns Location [https://domain.tld/] in Response Headers, ' \
                     'got https://www.domain.tld/' do
      before do
        stub_request(:head, domain)
          .to_return(status: 301, headers: { 'Location': 'https://www.domain.tld/' })
      end
    end
  end

  context 'when request redirected to expected location' do
    include_examples 'Plugin success' do
      before do
        stub_request(:head, domain)
          .to_return(status: 301, headers: { 'Location': 'https://domain.tld/' })
      end
    end
  end
end
