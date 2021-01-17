# frozen_string_literal: true

RSpec.describe Plugins::HTTP::HTTPToHttpsRedirectPlugin do
  subject(:execution) { described_class.new.call(opts) }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'Redirect from HTTP to HTTPS'

  include_examples 'validate plugin opts'

  context 'when HTTPClient raises exceptions' do
    let(:domain) { 'domain.tld' }

    include_examples 'HTTPClient Exceptions', :head, 'domain.tld'
  end

  include_examples 'Plugin success' do
    let(:domain) { 'domain.tld' }

    before do
      stub_request(:head, domain)
        .to_return(status: 301, headers: { 'Location': 'https://domain.tld/' })
    end
  end
end
