# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Other
    # Checks for database connection error message
    class DatabaseConnectionIssuePlugin < Base
      include Dry::Monads::Do.for(:call)

      def call(opts)
        values   = yield validate_opts(opts)
        response = yield request_get(values[:host])

        yield contains_string?(response[:body], 'access denied for user')

        Success(yield build_presentation(success: true))
      end

      def name
        'Database Connection Issue'
      end

      protected

      def contains_string?(body, expected)
        content = body.downcase.force_encoding('UTF-8')

        return Success() unless content.include?(expected)

        Failure('Database connection error found')
      end
    end
  end
end
