# frozen_string_literal: true

require_relative 'system/container'

Application.finalize!

Application['app'].call
