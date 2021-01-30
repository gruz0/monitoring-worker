# frozen_string_literal: true

require_relative './base_reporter'

module Utils
  class Reporter
    class StdoutReporter < BaseReporter
      def call(args)
        log_info 'StdoutReporter started'

        puts JSON.generate(args)

        log_info 'StdoutReporter finished'
      rescue StandardError => e
        log_error e.message
      end
    end
  end
end
