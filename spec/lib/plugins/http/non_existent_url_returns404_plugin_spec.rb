# frozen_string_literal: true

RSpec.describe Plugins::HTTP::NonExistentUrlReturns404Plugin do
  subject(:execution) { described_class.new.call(opts) }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'HTTP Status 404 for non-existent URL'

  describe 'validate opts' do
    include_examples 'validate plugin opts'
  end

  context 'when HTTPClient raises exceptions' do
    include_examples 'HTTPClient Exceptions', :head, 'domain.tld'
  end

  context 'when HTTP Status is not expected' do
    include_examples 'Plugin Failure with Matched Message',
                     'Expected URL \\[http://domain\.tld\/(.+)\\] returns \\[404\\] HTTP Status Code, got 200' do
      before do
        stub_request(:head, /#{domain}/)
          .to_return(status: 200)
      end
    end
  end

  context 'when HTTP Status is equal to expected' do
    include_examples 'Plugin success' do
      before do
        stub_request(:head, /#{domain}/)
          .to_return(status: 404)
      end
    end
  end
end
