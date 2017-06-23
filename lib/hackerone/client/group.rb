module HackerOne
  module Client
    class Group
      delegate :name, :permissions, to: :attributes

      def initialize(group)
        @group = group
      end

      def id
        @group[:id]
      end

      private

      def attributes
        OpenStruct.new(@group[:attributes])
      end
    end
  end
end
