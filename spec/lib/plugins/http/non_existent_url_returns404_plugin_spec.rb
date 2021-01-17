# frozen_string_literal: true

RSpec.describe Plugins::HTTP::NonExistentUrlReturns404Plugin do
  subject(:execution) { described_class.new.call(opts) }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'HTTP Status 404 for non-existent URL'

  include_examples 'validate plugin opts'

  context 'when HTTPClient raises exceptions' do
    let(:domain) { 'domain.tld' }

    include_examples 'HTTPClient Exceptions', :head, 'domain.tld'
  end

  include_examples 'Plugin success' do
    let(:domain) { 'domain.tld' }

    before do
      stub_request(:head, /#{domain}/)
        .to_return(status: 404)
    end
  end
end
