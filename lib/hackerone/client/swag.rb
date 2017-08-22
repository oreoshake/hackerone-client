module HackerOne
  module Client
    class Swag
      delegate :sent, to: :attributes

      def initialize(swag)
        @swag = swag
      end

      def id
        @swag[:id]
      end

      private

      def attributes
        OpenStruct.new(@swag[:attributes])
      end
    end
  end
end
