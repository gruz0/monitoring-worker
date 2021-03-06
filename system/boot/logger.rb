# frozen_string_literal: true

Application.boot(:logger) do
  init do
    require 'logstash-logger'
  end

  start do
    logstash_logger = LogStashLogger.new(
      type: :file,
      path: "log/worker.#{Application.env}.log",
      sync: true,
      customize_event: lambda do |event|
        event['worker_id'] = Application[:settings].monitoring_worker_id
        event['request_id'] = Application[:settings].monitoring_request_id
      end
    )

    register(:logger, logstash_logger)
  end
end
