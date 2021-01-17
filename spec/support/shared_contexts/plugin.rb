# frozen_string_literal: true

shared_context 'set plugin opts' do # rubocop:disable RSpec/ContextWording
  let(:opts) do
    {
      scheme: scheme,
      domain: domain,
      host: "#{scheme}://#{domain}"
    }
  end

  let(:scheme) { 'http' }
  let(:domain) { 'domain.tld' }
end

shared_context 'set plugin name' do |name| # rubocop:disable RSpec/ContextWording
  let(:plugin_name) { name }
end
