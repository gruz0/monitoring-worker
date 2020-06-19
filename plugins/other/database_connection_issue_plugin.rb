# frozen_string_literal: true

module Plugins
  module Other
    # Checks for database connection error message
    class DatabaseConnectionIssuePlugin < Base
      def call(domain_name)
        response = fetch('http://' + domain_name + '/')

        check_for_database_connection_error(response)

        success
      rescue PluginError => e
        failure(e.message)
      end

      def name
        'Database Connection Issue'
      end

      private

      def check_for_database_connection_error(response)
        return unless response.body.downcase.include?('access denied for user')

        raise PluginError, 'Database connection issue found'
      end
    end
  end
end
