# frozen_string_literal: true

module Utils
  class Reporter
    class StdoutReporter
      def call(args)
        puts args.inspect
      end
    end
  end
end
