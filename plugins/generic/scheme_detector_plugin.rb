# frozen_string_literal: true

module Plugins
  module Generic
    # Returns scheme
    class SchemeDetectorPlugin < Base
      def call(domain)
        response = fetch('http://' + domain)

        response.uri.scheme
      end

      def name
        'Scheme Detector'
      end
    end
  end
end
