# frozen_string_literal: true

ENV['MONITORING_WORKER_ENV'] = 'test'
ENV['MONITORING_WORKER_ID'] = 'test-worker-id'

Dir['./spec/support/**/*.rb'].sort.each { |file| require file }

require 'dry/system/stubs'
require 'dry/monads/all'

require_relative '../system/container'
require_relative '../system/import'

Application.enable_stubs!
Application.finalize!

RSpec.configure do |config|
  include Dry::Monads

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true
  config.profile_examples = 10
  config.order = :random

  Kernel.srand config.seed
end
