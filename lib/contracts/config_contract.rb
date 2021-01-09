# frozen_string_literal: true

module Contracts
  class ConfigContract < Dry::Validation::Contract
    # rubocop:disable Metrics/BlockLength
    params do
      optional(:verbose).filled(:integer)
      required(:domain).filled(:string)

      required(:plugins).filled(:hash).schema do
        optional(:content).filled(:hash).schema do
          optional(:contains_string).filled(:hash).schema do
            required(:enable).filled(:integer)
            required(:resource).filled(:string)
            required(:value).filled(:string)
          end
          optional(:does_not_contain_string).filled(:hash).schema do
            required(:enable).filled(:integer)
            required(:resource).filled(:string)
            required(:value).filled(:string)
          end
        end
        optional(:http).filled(:hash).schema do
          optional(:http_to_https_redirect).filled(:hash).schema do
            required(:enable).filled(:integer)
          end
          optional(:www_to_non_www_redirect).filled(:hash).schema do
            required(:enable).filled(:integer)
          end
          optional(:http_status200).filled(:hash).schema do
            required(:enable).filled(:integer)
          end
          optional(:non_existent_url_returns404).filled(:hash).schema do
            required(:enable).filled(:integer)
          end
          optional(:valid_http_status_code).filled(:hash).schema do
            required(:enable).filled(:integer)
            required(:resource).filled(:string)
            required(:value).filled(:integer)
          end
        end
        optional(:other).filled(:hash).schema do
          optional(:database_connection_issue).filled(:hash).schema do
            required(:enable).filled(:integer)
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
