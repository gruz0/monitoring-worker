# frozen_string_literal: true

require 'plugins/base'

module Plugins
  module Other
    # Checks for database connection error message
    class DatabaseConnectionIssuePlugin < Base
      include Dry::Monads::Do.for(:call)

      def call(input)
        opts     = yield validate_opts(input)
        response = yield request_get(opts[:host])

        yield contains_string?(response, 'access denied for user')

        success
      end

      def name
        'Database Connection Issue'
      end

      protected

      def contains_string?(response, expected)
        content = response[:body].downcase.force_encoding('UTF-8')

        return Success() unless content.include?(expected)

        Failure('Database connection error found')
      end
    end
  end
end
