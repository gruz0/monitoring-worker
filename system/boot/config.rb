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

    Config.load_and_set_settings('config/settings.yml')
  rescue Config::Validation::Error => e
    puts e.message
    exit 1
  end

  start do
    register(:config, Settings)
  end
end
