# frozen_string_literal: true

require 'dry/system/container'

class Application < Dry::System::Container
  load_paths!('lib')

  configure do |config|
    config.auto_register = %w[lib]
  end
end
