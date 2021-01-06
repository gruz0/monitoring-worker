# frozen_string_literal: true

# Represents contract
class ConfigContract < Dry::Validation::Contract
  params do
    optional(:verbose).filled(:integer)
    required(:domain).filled(:string)

    required(:plugins).filled(:hash).schema do
      optional(:http).filled(:hash).schema do
        optional(:http_to_https_redirect).filled(:integer)
        optional(:www_to_non_www_redirect).filled(:integer)
        optional(:http_status200).filled(:integer)
        optional(:non_existent_url_returns404).filled(:integer)
      end
      optional(:other).filled(:hash).schema do
        optional(:database_connection_issue).filled(:integer)
      end
    end
  end
end

Config.setup do |config|
  config.fail_on_missing = true

  config.use_env = true
  config.env_prefix = 'SETTINGS'
  config.env_separator = '__'
  config.env_parse_values = true

  config.validation_contract = ConfigContract.new
end

begin
  Config.load_and_set_settings('config/settings.yml')
rescue Config::Validation::Error => e
  puts e.message
  exit 1
end
