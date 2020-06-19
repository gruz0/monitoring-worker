# frozen_string_literal: true

# Represents Response as object
class Result
  attr_reader :success, :description

  def initialize(success:, description: nil)
    @success = success
    @description = description

    raise ArgumentError, 'Description must be set for failured result' unless valid?
  end

  def success?
    @success == true
  end

  def failure?
    !success?
  end

  protected

  def valid?
    success? || (failure? && !description_empty?)
  end

  def description_empty?
    description.to_s.strip.size.zero?
  end
end
