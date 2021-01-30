# frozen_string_literal: true

require_relative '../../utils/reporter'

Application.boot(:reporter) do
  start do
    kind = ENV.fetch('MONITORING_WORKER_REPORTER', :stdout).to_sym

    register(:reporter, Utils::Reporter.new(kind))
  end
end
