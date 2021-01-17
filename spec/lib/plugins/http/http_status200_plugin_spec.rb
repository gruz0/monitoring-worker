# frozen_string_literal: true

RSpec.describe Plugins::HTTP::HTTPStatus200Plugin do
  subject(:execution) { described_class.new.call(opts) }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'HTTP Status 200'

  include_examples 'validate plugin opts'

  context 'when HTTPClient raises exceptions' do
    let(:domain) { 'domain.tld' }

    include_examples 'HTTPClient Exceptions', :get, 'domain.tld'
  end

  include_examples 'Plugin success' do
    let(:domain) { 'domain.tld' }

    before do
      stub_request(:get, domain)
        .to_return(status: 200)
    end
  end
end
