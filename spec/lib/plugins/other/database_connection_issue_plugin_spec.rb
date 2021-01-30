# frozen_string_literal: true

RSpec.describe Plugins::Other::DatabaseConnectionIssuePlugin do
  subject(:execution) { described_class.new.call(opts) }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'database_connection_issue'

  describe 'validate opts' do
    include_examples 'validate plugin opts'
  end

  context 'when HTTPClient raises exceptions' do
    include_examples 'HTTPClient Exceptions', :get, 'domain.tld'
  end

  context 'when error string found' do
    context 'when case matches' do
      include_examples 'Plugin Failure with Message', 'Database connection error found' do
        before do
          stub_request(:get, domain)
            .to_return(status: 200, body: 'access denied for user')
        end
      end
    end

    context 'when case does not match' do
      include_examples 'Plugin Failure with Message', 'Database connection error found' do
        before do
          stub_request(:get, domain)
            .to_return(status: 200, body: 'Access Denied for user')
        end
      end
    end
  end

  context 'when error string does not exist' do
    include_examples 'Plugin success' do
      before do
        stub_request(:get, domain)
          .to_return(status: 200, body: 'content')
      end
    end
  end
end
