require_relative './weakness'
require_relative './activity'

module HackerOne
  module Client
    class Reporter
      def initialize(reporter)
        @reporter = reporter
      end

      def id
        @reporter[:id]
      end

      def attributes
        @reporter[:attributes]
      end

      def username
        attributes[:username]
      end

      def name
        attributes[:name]
      end

      def disabled?
        attributes[:disabled]
      end

      def created_at
        attributes[:created_at]
      end
    end
  end
end
