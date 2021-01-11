# frozen_string_literal: true

RSpec.describe Plugins::Generic::DomainDetectorPlugin do
  subject(:result) { described_class.new.call(domain) }

  let(:domain) { 'http://domain.tld/123' }

  let(:attrs) do
    {
      plugin_class: described_class.name,
      plugin_name: 'Domain Detector'
    }
  end

  it { is_expected.to eq(Success(attrs.merge(value: 'domain.tld'))) }

  context 'when domain is nil' do
    let(:domain) {}

    it { is_expected.to eq(Failure(attrs.merge(value: 'URL must not be empty'))) }
  end

  context 'when domain is empty' do
    let(:domain) { ' ' }

    it { is_expected.to eq(Failure(attrs.merge(value: 'URL must not be empty'))) }
  end

  context 'when domain without scheme' do
    let(:domain) { 'domain.tld/123' }

    it { is_expected.to eq(Success(attrs.merge(value: 'domain.tld'))) }
  end

  context 'when domain has www subdomain' do
    let(:domain) { 'http://www.domain.tld/123' }

    it { is_expected.to eq(Success(attrs.merge(value: 'domain.tld'))) }
  end
end
