# frozen_string_literal: true

require_relative 'system/boot'

app    = Application[:app]
config = Application[:config]
logger = Application[:logger]

result = app.call(config.domain, config.plugins.to_hash)

result.each do |r|
  logger.debug r
end
