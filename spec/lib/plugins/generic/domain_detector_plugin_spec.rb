# frozen_string_literal: true

RSpec.describe Plugins::Generic::DomainDetectorPlugin do
  subject(:execution) { described_class.new.call(input) }

  include_context 'set plugin name', 'domain_detector'

  let(:input) { {} }

  shared_examples 'DomainDetectorPlugin Success' do |domain_name|
    let(:attrs) do
      {
        plugin_namespace: plugin_namespace(described_class),
        plugin_name: 'domain_detector',
        domain: domain_name
      }
    end

    it 'is Success' do
      expect(execution).to eq(Success(attrs))
    end
  end

  context 'when domain is missing' do
    before { input.delete(:domain) }

    include_examples 'Plugin Failure', 'domain is missing'
  end

  context 'when domain is nil' do
    before { input[:domain] = nil }

    include_examples 'Plugin Failure', 'domain must be filled'
  end

  context 'when domain is not a string' do
    before { input[:domain] = false }

    include_examples 'Plugin Failure', 'domain must be a string'
  end

  context 'when domain is empty' do
    before { input[:domain] = ' ' }

    include_examples 'Plugin Failure', 'domain must be filled'
  end

  context 'when domain could not be parsed' do
    before { input[:domain] = '"' }

    include_examples 'Plugin Failure', 'domain is not valid'
  end

  context 'when domain without scheme' do
    before { input[:domain] = 'domain.tld/123' }

    include_examples 'DomainDetectorPlugin Success', 'domain.tld'
  end

  context 'when domain has scheme and resource' do
    before { input[:domain] = 'http://domain.tld/123' }

    include_examples 'DomainDetectorPlugin Success', 'domain.tld'
  end

  context 'when domain has www subdomain' do
    before { input[:domain] = 'http://www.domain.tld/123' }

    include_examples 'DomainDetectorPlugin Success', 'domain.tld'
  end
end
