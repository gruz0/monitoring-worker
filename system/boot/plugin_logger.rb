# frozen_string_literal: true

Application.boot(:plugin_logger) do
  init do
    require 'logstash-logger'
  end

  start do
    logstash_logger = LogStashLogger.new(
      type: :file,
      path: "log/plugin.#{Application.env}.log",
      sync: true,
      customize_event: lambda do |event|
        event['worker_id'] = Application[:settings].monitoring_worker_id
        event['request_id'] = Application[:settings].monitoring_request_id
      end
    )

    register(:plugin_logger, logstash_logger)
  end
end
