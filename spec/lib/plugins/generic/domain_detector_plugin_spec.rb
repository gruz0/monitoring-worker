# frozen_string_literal: true

RSpec.describe Plugins::Generic::DomainDetectorPlugin do
  subject(:execution) { described_class.new.call(domain) }

  let(:domain) { 'http://domain.tld/123' }

  shared_examples 'DomainDetectorPlugin Success' do |domain_name|
    let(:attrs) do
      {
        plugin_class: described_class.name,
        plugin_name: 'Domain Detector',
        domain: domain_name
      }
    end

    it 'is Success' do
      expect(execution).to eq(Success(attrs))
    end
  end

  include_examples 'DomainDetectorPlugin Success', 'domain.tld'

  context 'when domain is nil' do
    let(:domain) {}

    it { is_expected.to eq(Failure('Domain must be a string')) }
  end

  context 'when domain is empty' do
    let(:domain) { ' ' }

    it { is_expected.to eq(Failure('Domain must not be empty')) }
  end

  context 'when domain could not be parsed' do
    let(:domain) { '"' }

    it { is_expected.to eq(Failure('Invalid domain name')) }
  end

  context 'when domain without scheme' do
    let(:domain) { 'domain.tld/123' }

    include_examples 'DomainDetectorPlugin Success', 'domain.tld'
  end

  context 'when domain has www subdomain' do
    let(:domain) { 'http://www.domain.tld/123' }

    include_examples 'DomainDetectorPlugin Success', 'domain.tld'
  end
end
