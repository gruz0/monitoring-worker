# frozen_string_literal: true

RSpec.describe Plugins::HTTP::ValidHTTPStatusCodePlugin do
  subject(:execution) { described_class.new.call(opts) }

  include_context 'set plugin opts'
  include_context 'set plugin name', 'Valid HTTP Status Code'

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

    context 'when meta[value] is not an integer' do
      before do
        opts[:meta] = { resource: '/resource', value: '2' }
      end

      it { is_expected.to eq(Failure('Value must be an integer')) }
    end
  end

  context 'when HTTPClient raises exceptions' do
    let(:domain) { 'domain.tld' }

    before do
      opts[:meta] = { resource: '/resource', value: 200 }
    end

    include_examples 'HTTPClient Exceptions', :head, 'domain.tld'
  end

  context 'with valid opts and meta' do
    include_examples 'Plugin success' do
      let(:domain) { 'domain.tld' }

      before do
        opts[:meta] = { resource: '/resource', value: 200 }

        stub_request(:head, "http://#{domain}/resource")
          .to_return(status: 200)
      end
    end
  end
end
