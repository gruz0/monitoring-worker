# frozen_string_literal: true

RSpec.describe Plugins::Other::DatabaseConnectionIssuePlugin do
  subject(:execution) { described_class.new.call(opts) }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'Database Connection Issue'

  include_examples 'validate plugin opts'

  context 'when HTTPClient raises exceptions' do
    let(:domain) { 'domain.tld' }

    include_examples 'HTTPClient Exceptions', :get, 'domain.tld'
  end

  context 'when error string found' do
    let(:domain) { 'domain.tld' }

    context 'when case matches' do
      before do
        stub_request(:get, domain)
          .to_return(status: 200, body: 'access denied for user')
      end

      it { is_expected.to eq(Failure('Database connection error found')) }
    end

    context 'when case does not match' do
      before do
        stub_request(:get, domain)
          .to_return(status: 200, body: 'Access Denied for user')
      end

      it { is_expected.to eq(Failure('Database connection error found')) }
    end
  end

  context 'when error string does not exist' do
    include_examples 'Plugin success' do
      let(:domain) { 'domain.tld' }

      before do
        stub_request(:get, domain)
          .to_return(status: 200, body: 'content')
      end
    end
  end
end
