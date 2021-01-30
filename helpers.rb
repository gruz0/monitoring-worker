# frozen_string_literal: true

def calculate_time_in_ms(started_at)
  (1000 * (Time.now.to_f - started_at)).to_i
end

def log_exception(logger, error)
  logger.fatal do
    {
      message: error.message,
      backtrace: error.backtrace.first(5)
    }
  end
end
