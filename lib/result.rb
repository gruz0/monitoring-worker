# frozen_string_literal: true

# Represents plugin's result as object
class Result
  attr_reader :success, :plugin_name, :value

  def initialize(success:, plugin_name:, value: nil)
    @success = success
    @plugin_name = plugin_name
    @value = value
  end

  def success?
    @success == true
  end

  def failure?
    !success?
  end
end
