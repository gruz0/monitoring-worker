# frozen_string_literal: true

require 'dry/events/listener'
require_relative 'helpers'
require_relative 'system/boot'

include Dry::Events::Listener[:app_publisher]

started_at = Time.now.to_f
app        = Application[:app]
config     = Application[:config]
logger     = Application[:logger]
reporter   = Application[:reporter]

subscribe(:checked) do |payload|
  reporter.call(
    domain: config.domain,
    opts: payload[:opts],
    meta: payload[:meta],
    report: payload[:report],
    took: payload[:took]
  )
rescue Exception => e # rubocop:disable Lint/RescueException
  log_exception(logger, e)
end

logger.info { { message: 'Worker started', domain: config.domain } }

begin
  app.call(config.domain, config.plugins.to_hash)
rescue Exception => e # rubocop:disable Lint/RescueException
  log_exception(logger, e)
end

logger.info { { message: 'Worker finished', domain: config.domain, took: calculate_time_in_ms(started_at) } }
