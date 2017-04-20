module HackerOne
  module Client
    class Program
      delegate :handle, to: :attributes

      def initialize(program)
        @program = program
      end

      def id
        @program[:id]
      end

      def attributes
        OpenStruct.new @program[:attributes]
      end
    end
  end
end
