# frozen_string_literal: true

require 'json'
require_relative './reporter/loggable'
require_relative './reporter/stdout_reporter'
require_relative './reporter/api_reporter'

module Utils
  class Reporter
    class UnknownKindError < StandardError; end
    include Loggable

    def initialize(kind:, logger:)
      @kind   = kind
      @logger = logger
    end

    def call(domain:, opts:, meta:, report:, took:)
      log_info 'Reporter started'

      reporter = pick_reporter_by_kind(kind)

      builded_report = build_report(domain, opts, meta, report, took)

      log_info 'Report builded', report: builded_report

      reporter.call(builded_report)

      log_info 'Reporter finished'
    rescue StandardError => e
      log_error e.message
    end

    private

    attr_reader :kind

    def pick_reporter_by_kind(kind)
      case kind
      when :stdout
        @reporter = stdout_reporter
      when :api
        @reporter = api_reporter
      else
        raise UnknownKindError, "No reporter with given kind=#{kind} was found"
      end
    end

    def build_report(domain, opts, meta, report, took) # rubocop:disable Metrics/MethodLength
      value = report.success? ? report.value! : report.failure

      {
        domain: domain,
        plugin_namespace: value[:plugin_namespace],
        plugin_name: value[:plugin_name],
        plugin_opts: opts,
        plugin_meta: meta,
        success: report.success?,
        checked_at: Time.now.utc,
        took: took,
        error: value[:error]
      }
    end

    def stdout_reporter
      StdoutReporter.new(logger: logger)
    end

    def api_reporter
      ApiReporter.new(logger: logger)
    end
  end
end
