# frozen_string_literal: true

require_relative './reporter/stdout_reporter'
require_relative './reporter/api_reporter'

module Utils
  class Reporter
    class UnknownKindError < StandardError; end

    def initialize(kind)
      @reporter = pick_reporter_by_kind(kind)
    end

    def call(domain:, opts:, meta:, report:, took:)
      reporter.call(build_report(domain, opts, meta, report, took))
    end

    private

    attr_reader :reporter

    def pick_reporter_by_kind(kind)
      case kind
      when :stdout
        @reporter = stdout_reporter
      when :api
        @reporter = api_reporter
      else
        raise UnknownKindError, 'No reporter with given kind was foud'
      end
    end

    def build_report(domain, opts, meta, report, took) # rubocop:disable RSpec/MethodLength
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
      StdoutReporter.new
    end

    def api_reporter
      ApiReporter.new
    end
  end
end
