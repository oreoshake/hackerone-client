module HackerOne
  module Client
    class Me
      delegate :id, to: :attributes

      def initialize(program)
        @program = program
      end

      def attributes
        OpenStruct.new(@me[:attributes])
      end
    end
  end
end
