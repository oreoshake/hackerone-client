require_relative './weakness'
require_relative './activity'

module HackerOne
  module Client
    class Program
      def initialize(program)
        @program = program
      end

      def id
        @program[:id]
      end

      def handle
        attributes[:handle]
      end

      def attributes
        @program[:attributes]
      end
    end
  end
end
