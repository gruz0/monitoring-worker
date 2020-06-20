# frozen_string_literal: true

# Represents contract
class ConfigContract < Dry::Validation::Contract
  config.validate_keys = true

  params do
    optional(:verbose).filled(:bool)
    required(:domain).filled(:string)

    required(:plugins).filled(:hash).schema do
      optional(:http).array(:str?)
      optional(:other).array(:str?)
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
