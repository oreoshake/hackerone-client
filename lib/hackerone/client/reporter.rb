module HackerOne
  module Client
    class Reporter
      delegate :username, :name, :created_at, to: :attributes

      def initialize(reporter)
        @reporter = reporter
      end

      def id
        @reporter[:id]
      end

      def attributes
        OpenStruct.new(@reporter[:attributes])
      end

      def disabled?
        attributes.disabled
      end
    end
  end
end
