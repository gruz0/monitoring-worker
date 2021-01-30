# frozen_string_literal: true

RSpec.describe Plugins::HTTP::ValidHTTPStatusCodePlugin do
  subject(:execution) { described_class.new.call(opts) }

  let(:enable) { 1 }
  let(:resource) { '/resource' }
  let(:value) { 200 }
  let(:meta) do
    {
      enable: enable,
      resource: resource,
      value: value
    }
  end

  before { opts[:meta] = meta }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'valid_http_status_code'

  describe 'validate opts' do
    include_examples 'validate plugin opts'
  end

  include_examples 'validate plugin meta' do
    describe ':resource' do
      context 'when :resource is not a string' do
        let(:resource) { false }

        include_examples 'Plugin Failure', 'resource must be a string'
      end

      context 'when :resource is empty' do
        let(:resource) { '' }

        include_examples 'Plugin Failure', 'resource must be filled'
      end

      context 'when :resource does not have a leading slash' do
        let(:resource) { 'resource' }

        include_examples 'Plugin Failure', 'resource must be started with a leading slash'
      end
    end

    describe ':value' do
      context 'when :value is not an integer' do
        let(:value) { 'test' }

        include_examples 'Plugin Failure', 'value must be an integer'
      end

      context 'when :value is empty' do
        let(:value) { '' }

        include_examples 'Plugin Failure', 'value must be filled'
      end
    end
  end

  context 'when HTTPClient raises exceptions' do
    include_examples 'HTTPClient Exceptions', :head, 'domain.tld'
  end

  context 'when HTTP Status is not expected' do
    include_examples 'Plugin Failure with Message',
                     'Expected URL [http://domain.tld/resource] returns [200] HTTP Status Code, got 204' do
      before do
        stub_request(:head, "http://#{domain}/resource")
          .to_return(status: 204)
      end
    end
  end

  context 'when HTTP Status is equal to expected' do
    include_examples 'Plugin success' do
      before do
        stub_request(:head, "http://#{domain}/resource")
          .to_return(status: 200)
      end
    end
  end
end
