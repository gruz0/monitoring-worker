# frozen_string_literal: true

# Formats message depends on check's result
class MessageFormatter
  MESSAGE_FORMAT = '[%s] %s: %s'

  # @param [Plugin] plugin
  # @param [String] domain_name
  # @param [Result] result
  def call(plugin:, domain_name:, result:)
    format(MESSAGE_FORMAT, status(result), plugin.name, domain_name)
  end

  private

  def status(result)
    result.success? ? 'PASSED' : 'FAILED'
  end
end
