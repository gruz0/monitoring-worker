# frozen_string_literal: true

shared_context 'logger' do # rubocop:disable RSpec/ContextWording
  let(:logger) { instance_double('Logger') }

  before do
    allow(logger).to receive(:fatal)
    allow(logger).to receive(:error)
    allow(logger).to receive(:warn)
    allow(logger).to receive(:info)
    allow(logger).to receive(:debug)

    Application.stub('logger', logger)
  end
end
