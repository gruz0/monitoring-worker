# frozen_string_literal: true

RSpec.describe Plugins::Content::DoesNotContainStringPlugin do
  subject(:execution) { described_class.new.call(opts) }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'Does not Contain String'

  include_examples 'validate plugin opts'

  include_examples 'validate plugin meta' do
    context 'when meta does not have a resource' do
      before do
        opts[:meta] = { test: 1 }
      end

      it { is_expected.to eq(Failure('Meta must have :resource')) }
    end

    context 'when meta[resource] is not a string' do
      before do
        opts[:meta] = { resource: 1 }
      end

      it { is_expected.to eq(Failure('Resource must be a string')) }
    end

    context 'when meta[resource] is empty' do
      before do
        opts[:meta] = { resource: ' ' }
      end

      it { is_expected.to eq(Failure('Resource must not be empty')) }
    end

    context 'when meta[resource] does not have leading slash' do
      before do
        opts[:meta] = { resource: 'resource' }
      end

      it { is_expected.to eq(Failure('Resource must be started with leading slash')) }
    end

    context 'when meta does not have value' do
      before do
        opts[:meta] = { resource: '/resource', test: 1 }
      end

      it { is_expected.to eq(Failure('Meta must have :value')) }
    end

    context 'when meta[value] is not a string' do
      before do
        opts[:meta] = { resource: '/resource', value: 1 }
      end

      it { is_expected.to eq(Failure('Value must be a string')) }
    end

    context 'when meta[value] is empty' do
      before do
        opts[:meta] = { resource: '/resource', value: ' ' }
      end

      it { is_expected.to eq(Failure('Value must not be empty')) }
    end
  end

  context 'when HTTPClient raises exceptions' do
    let(:domain) { 'domain.tld' }

    before do
      opts[:meta] = { resource: '/resource', value: 'expected' }
    end

    include_examples 'HTTPClient Exceptions', :get, 'domain.tld'
  end

  context 'when expected content exists' do
    let(:domain) { 'domain.tld' }

    context 'when case matches' do
      before do
        opts[:meta] = { resource: '/resource', value: 'слово' }

        stub_request(:get, "http://#{domain}/resource")
          .to_return(status: 200, body: 'слово')
      end

      it { is_expected.to eq(Failure('Expected content exists')) }
    end

    context 'when case does not match' do
      before do
        opts[:meta] = { resource: '/resource', value: 'СЛОВО' }

        stub_request(:get, "http://#{domain}/resource")
          .to_return(status: 200, body: 'слово')
      end

      it { is_expected.to eq(Failure('Expected content exists')) }
    end
  end

  context 'when expected content does not exist' do
    include_examples 'Plugin success' do
      let(:domain) { 'domain.tld' }

      before do
        opts[:meta] = { resource: '/resource', value: 'слово' }

        stub_request(:get, "http://#{domain}/resource")
          .to_return(status: 200, body: 'content')
      end
    end
  end
end
