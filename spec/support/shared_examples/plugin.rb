# frozen_string_literal: true

shared_examples 'validate plugin opts' do
  describe 'scheme' do
    context 'when scheme is missing' do
      before { opts.delete(:scheme) }

      include_examples 'Plugin Failure', { scheme: ['scheme is missing'] }
    end

    context 'when scheme is nil' do
      before { opts[:scheme] = nil }

      include_examples 'Plugin Failure', { scheme: ['scheme must be filled'] }
    end

    context 'when scheme is not a string' do
      before { opts[:scheme] = 42 }

      include_examples 'Plugin Failure', { scheme: ['scheme must be a string'] }
    end

    context 'when scheme is empty' do
      before { opts[:scheme] = ' ' }

      include_examples 'Plugin Failure', { scheme: ['scheme must be one of: http, https'] }
    end

    context 'with invalid scheme' do
      before { opts[:scheme] = 'ftp' }

      include_examples 'Plugin Failure', { scheme: ['scheme must be one of: http, https'] }
    end
  end

  describe 'domain' do
    context 'when domain is missing' do
      before { opts.delete(:domain) }

      include_examples 'Plugin Failure', { domain: ['domain is missing'] }
    end

    context 'when domain is nil' do
      before { opts[:domain] = nil }

      include_examples 'Plugin Failure', { domain: ['domain must be filled'] }
    end

    context 'when domain is not a string' do
      before { opts[:domain] = 42 }

      include_examples 'Plugin Failure', { domain: ['domain must be a string'] }
    end

    context 'when domain is empty' do
      before { opts[:domain] = ' ' }

      include_examples 'Plugin Failure', { domain: ['domain must be filled'] }
    end

    context 'when domain has scheme' do
      ['http://', 'https://'].each do |scheme|
        before { opts[:domain] = scheme }

        include_examples 'Plugin Failure', { domain: ['domain must not have a scheme'] }
      end
    end
  end

  describe 'host' do
    context 'when host is missing' do
      before { opts.delete(:host) }

      include_examples 'Plugin Failure', { host: ['host is missing'] }
    end

    context 'when host is nil' do
      before { opts[:host] = nil }

      include_examples 'Plugin Failure', { host: ['host must be filled'] }
    end

    context 'when host is not a string' do
      before { opts[:host] = 42 }

      include_examples 'Plugin Failure', { host: ['host must be a string'] }
    end

    context 'when host is empty' do
      before { opts[:host] = ' ' }

      include_examples 'Plugin Failure', { host: ['host must be filled'] }
    end

    context 'when host is not a scheme + domain' do
      before do
        opts[:scheme] = 'http'
        opts[:domain] = 'domain.tld'
        opts[:host] = 'https://another-domain.tld'
      end

      include_examples 'Plugin Failure', { host: ['host has invalid value'] }
    end
  end
end

shared_examples 'validate plugin meta' do
  context 'when meta is missing' do
    before { opts.delete(:meta) }

    include_examples 'Plugin Failure', { meta: ['meta is missing'] }
  end

  context 'when meta is not a hash' do
    before { opts[:meta] = 1 }

    include_examples 'Plugin Failure', { meta: ['meta must be a hash'] }
  end

  context 'when meta is empty' do
    before { opts[:meta] = {} }

    include_examples 'Plugin Failure', { meta: ['meta must be filled'] }
  end

  context 'when :enable is not an integer' do
    let(:enable) { 'test' }

    include_examples 'Plugin Failure', { meta: { enable: ['enable must be an integer'] } }
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

shared_examples 'Plugin Failure' do |expected|
  it { is_expected.to be_failure }

  it 'includes error' do
    result = execution.failure
    expect(result).to include(expected)
  end
end

shared_examples 'Plugin Failure with Message' do |message|
  it { is_expected.to be_failure }

  it 'has error' do
    result = execution.failure
    expect(result).to eq(message)
  end
end

shared_examples 'Plugin Failure with Matched Message' do |message|
  it { is_expected.to be_failure }

  it 'matches error' do
    result = execution.failure
    expect(result).to match(/#{message}/)
  end
end
