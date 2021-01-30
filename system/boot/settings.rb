# frozen_string_literal: true

require 'dry/system/components'
require 'securerandom'
require_relative '../../lib/contracts/types'

Application.boot(:settings, from: :system) do
  settings do
    key :monitoring_worker_id, Types::String.constrained(filled: true)
    key :monitoring_request_id, Types::String.constrained(filled: true).default(SecureRandom.uuid.freeze)
  end
end
