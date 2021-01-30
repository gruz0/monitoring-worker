# frozen_string_literal: true

require_relative './base_reporter'

module Utils
  class Reporter
    class ApiReporter < BaseReporter
      def call(_args)
        log_info 'ApiReporter started'

        log_info 'ApiReporter finished'
      rescue StandardError => e
        log_error e.message
      end
    end
  end
end
