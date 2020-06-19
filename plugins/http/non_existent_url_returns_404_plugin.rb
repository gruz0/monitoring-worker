# frozen_string_literal: true

module Plugins
  module Http
    # Checks for HTTP Status 404 for non-existent URL
    class NonExistentUrlReturns404Plugin < Base
      def call(domain_name)
        response = request_head(domain_name, '/' + generate_random)

        check_for_unexpected_status_code(response, 404)

        success
      rescue PluginError => e
        failure(e.message)
      end

      def name
        'HTTP Status 404 for non-existent URL'
      end

      protected

      def generate_random
        rand(36**36).to_s(36)
      end
    end
  end
end
