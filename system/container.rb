# frozen_string_literal: true

require 'dry/system/container'

class Application < Dry::System::Container
  use :env, inferrer: -> { ENV.fetch('MONITORING_WORKER_ENV', :development).to_sym }

  configure do |config|
    config.auto_register = 'lib'
  end

  load_paths!('lib', 'system')
end
