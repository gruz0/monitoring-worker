# frozen_string_literal: true

RSpec.describe Plugins::HTTP::WwwToNonWwwRedirectPlugin do
  subject(:execution) { described_class.new.call(opts) }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'Redirect from www to non-www'

  include_examples 'validate plugin opts'

  context 'when HTTPClient raises exceptions' do
    let(:domain) { 'domain.tld' }

    include_examples 'HTTPClient Exceptions', :head, 'www.domain.tld'
  end

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
