# frozen_string_literal: true

RSpec.describe Plugins::Content::ContainsStringPlugin do
  subject(:execution) { described_class.new.call(opts) }

  let(:enable) { 1 }
  let(:resource) { '/resource' }
  let(:value) { 'content' }
  let(:meta) do
    {
      enable: enable,
      resource: resource,
      value: value
    }
  end

  before { opts[:meta] = meta }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'Contains String'

  describe 'validate opts' do
    include_examples 'validate plugin opts'
  end

  include_examples 'validate plugin meta' do
    describe ':resource' do
      context 'when :resource is not a string' do
        let(:resource) { false }

        include_examples 'Plugin Failure', { meta: { resource: ['resource must be a string'] } }
      end

      context 'when :resource is empty' do
        let(:resource) { '' }

        include_examples 'Plugin Failure', { meta: { resource: ['resource must be filled'] } }
      end

      context 'when :resource does not have a leading slash' do
        let(:resource) { 'resource' }

        include_examples 'Plugin Failure', { meta: { resource: ['resource must be started with a leading slash'] } }
      end
    end

    describe ':value' do
      context 'when :value is not a string' do
        let(:value) { false }

        include_examples 'Plugin Failure', { meta: { value: ['value must be a string'] } }
      end

      context 'when :value is empty' do
        let(:value) { '' }

        include_examples 'Plugin Failure', { meta: { value: ['value must be filled'] } }
      end
    end
  end

  context 'when HTTPClient raises exceptions' do
    include_examples 'HTTPClient Exceptions', :get, 'domain.tld'
  end

  context 'when expected content does not exist' do
    include_examples 'Plugin Failure with Message', 'Expected content does not exist' do
      let(:value) { 'слово' }

      before do
        stub_request(:get, "http://#{domain}/resource")
          .to_return(status: 200, body: 'content')
      end
    end
  end

  context 'when expected content exists' do
    context 'when case matches' do
      include_examples 'Plugin success' do
        let(:value) { 'слово' }

        before do
          stub_request(:get, "http://#{domain}/resource")
            .to_return(status: 200, body: 'проверочное слово')
        end
      end
    end

    context 'when case does not match' do
      include_examples 'Plugin success' do
        let(:value) { 'СЛОВО' }

        before do
          stub_request(:get, "http://#{domain}/resource")
            .to_return(status: 200, body: 'проверочное слово')
        end
      end
    end
  end
end
