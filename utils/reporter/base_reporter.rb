# frozen_string_literal: true

require 'json'
require_relative './loggable'

module Utils
  class Reporter
    class BaseReporter
      include Loggable

      def initialize(logger:)
        @logger = logger
      end

      def call(_)
        raise NotImplementedError, '#call must be implemented'
      end
    end
  end
end
