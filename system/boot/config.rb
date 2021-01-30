# frozen_string_literal: true

require 'dry-validation'
require 'config'

Application.boot(:config) do
  init do
    Config.setup do |config|
      config.fail_on_missing = true

      config.use_env = true
      config.env_prefix = 'SETTINGS'
      config.env_separator = '__'
      config.env_parse_values = true

      config.validation_contract = Application.resolve('contracts.config_contract')
    end

    config_path = Application.env == :test ? 'config/settings/test.yml' : 'config/settings.yml'

    Config.load_and_set_settings(config_path)
  rescue Config::Validation::Error => e
    Application[:logger].fatal e.message

    exit 1
  end

  start do
    register(:config, Settings)
  end
end
