# frozen_string_literal: true

module Utils
  class Reporter
    module Loggable
      def log_info(message, **args)
        logger.info { logger_attrs.merge(args).merge(args, message: message) }
      end

      def log_error(message)
        logger.error { logger_attrs.merge(message: message) }
      end

      def logger_attrs
        {
          class: self.class.name
        }
      end

      private

      attr_reader :logger
    end
  end
end
