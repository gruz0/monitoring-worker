# frozen_string_literal: true

require 'dry/events/listener'
require_relative 'system/boot'

include Dry::Events::Listener[:app_publisher]

app      = Application[:app]
config   = Application[:config]
reporter = Application[:reporter]

subscribe(:checked) do |payload|
  reporter.call(
    domain: config.domain,
    opts: payload[:opts],
    meta: payload[:meta],
    report: payload[:report],
    took: payload[:took]
  )
end

app.call(config.domain, config.plugins.to_hash)
