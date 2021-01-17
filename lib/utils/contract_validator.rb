# frozen_string_literal: true

require 'dry/monads'

Dry::Validation.load_extensions(:monads)

module Utils
  class ContractValidator
    include Dry::Monads[:result]

    def call(contract, input)
      case contract.call(input).to_monad
        in Success(result)
        Success(result.to_h)
        in Failure(result)
        Failure(result.errors(full: true).to_h)
      end
    end
  end
end
