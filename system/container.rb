# frozen_string_literal: true

require 'dry/system/container'

class Application < Dry::System::Container
  use :monitoring

  configure do |config|
    config.auto_register = 'lib'
  end

  load_paths!('lib', 'system')
end
