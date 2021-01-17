# frozen_string_literal: true

shared_examples 'HTTPClient Success' do |args|
  it 'includes values' do # rubocop:disable RSpec/MultipleExpectations
    result = execution.value!

    args.each do |key, value|
      expect(result).to have_key(key)
      expect(result[key]).to eq(value)
    end
  end
end

shared_examples 'HTTPClient Failure' do |message|
  it { is_expected.to eq(Failure(message)) }
end

shared_examples 'HTTPClient Exceptions' do |method, host_or_url|
  context 'when domain could not be resolved' do
    include_examples 'Stubbed HTTPClient raises SocketError', method, host_or_url
  end

  context 'when SSL certificate is not valid' do
    include_examples 'Stubbed HTTPClient raises OpenSSL::SSL::SSLError', method, host_or_url
  end

  context 'when open connection timed out' do
    include_examples 'Stubbed HTTPClient raises Net::OpenTimeout', method, host_or_url
  end

  context 'when read connection timed out' do
    include_examples 'Stubbed HTTPClient raises Timeout::Error', method, host_or_url
  end
end

shared_examples 'Stubbed HTTPClient raises SocketError' do |method, host_or_url|
  before do
    stub_request(method, /#{host_or_url}/)
      .to_raise(SocketError)
  end

  include_examples 'HTTPClient Failure', 'Socket Error: Domain does not resolve'
end

shared_examples 'Stubbed HTTPClient raises OpenSSL::SSL::SSLError' do |method, host_or_url|
  before do
    stub_request(method, /#{host_or_url}/)
      .to_raise(OpenSSL::SSL::SSLError)
  end

  include_examples 'HTTPClient Failure', 'SSL Error: Invalid certificate'
end

shared_examples 'Stubbed HTTPClient raises Net::OpenTimeout' do |method, host_or_url|
  before do
    stub_request(method, /#{host_or_url}/)
      .to_raise(Net::OpenTimeout)
  end

  include_examples 'HTTPClient Failure', 'Network Error: Open timeout'
end

shared_examples 'Stubbed HTTPClient raises Timeout::Error' do |method, host_or_url|
  before do
    stub_request(method, /#{host_or_url}/)
      .to_raise(Timeout::Error)
  end

  include_examples 'HTTPClient Failure', 'Timeout Error: Reading from server'
end
