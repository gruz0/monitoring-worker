# frozen_string_literal: true

# Represents contract
class ConfigContract < Dry::Validation::Contract
  config.validate_keys = true

  params do
    optional(:verbose).filled(:bool)

    required(:plugins).filled(:hash).schema do
      optional(:http).filled(:hash).schema do
        optional(:http_to_https_redirect).array(:str?)
        optional(:www_to_non_www_redirect).array(:str?)
        optional(:http_status_200).array(:str?)
        optional(:non_existent_url_returns_404).array(:str?)
      end
      optional(:other).filled(:hash).schema do
        optional(:database_connection_issue).array(:str?)
      end
    end
  end
end

Config.setup do |config|
  config.fail_on_missing = true

  config.validation_contract = ConfigContract.new
end

begin
  Config.load_and_set_settings('config/settings.yml')
rescue Config::Validation::Error => e
  puts e.message
  exit 1
end
