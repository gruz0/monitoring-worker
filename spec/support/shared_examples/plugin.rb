# frozen_string_literal: true

shared_examples 'validate plugin opts' do
  context 'when scheme is absent' do
    before { opts.delete(:scheme) }

    it { is_expected.to eq(Failure('Scheme must be present')) }
  end

  context 'when domain is absent' do
    before { opts.delete(:domain) }

    it { is_expected.to eq(Failure('Domain must be present')) }
  end

  context 'when host is absent' do
    before { opts.delete(:host) }

    it { is_expected.to eq(Failure('Host must be present')) }
  end

  context 'with empty scheme' do
    before { opts[:scheme] = ' ' }

    it { is_expected.to eq(Failure('Scheme must not be empty')) }
  end

  context 'with empty domain' do
    before { opts[:domain] = ' ' }

    it { is_expected.to eq(Failure('Domain must not be empty')) }
  end

  context 'with empty host' do
    before { opts[:host] = ' ' }

    it { is_expected.to eq(Failure('Host must not be empty')) }
  end

  context 'with invalid scheme' do
    before { opts[:scheme] = 'ftp' }

    it { is_expected.to eq(Failure('Scheme must be one of: http or https')) }
  end

  context 'when domain has a scheme' do
    before { opts[:domain] = 'http://domain.tld' }

    it { is_expected.to eq(Failure('Domain must not have a scheme')) }
  end

  context 'when host is not a scheme + domain' do
    before { opts[:host] = 'http://another-domain.tld' }

    it { is_expected.to eq(Failure('Host has invalid value')) }
  end
end

shared_examples 'validate plugin meta' do
  context 'when meta is absent' do
    it { is_expected.to eq(Failure('Meta must be present')) }
  end

  context 'when meta is not a hash' do
    before { opts[:meta] = 1 }

    it { is_expected.to eq(Failure('Meta must be a hash')) }
  end
end

shared_examples 'Plugin success' do
  let(:plugin_attrs) do
    {
      plugin_class: described_class.name,
      plugin_name: plugin_name
    }
  end

  it { is_expected.to eq(Success(plugin_attrs.merge(success: true))) }
end
