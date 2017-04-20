module HackerOne
  module Client
    class Program
      delegate :handle, to: :attributes

      def self.find(program_handle_we_want)
        my_programs.find do |program|
          program.handle == program_handle_we_want
        end
      end

      def initialize(program)
        @program = program
      end

      def id
        @program[:id]
      end

      def attributes
        OpenStruct.new(@program[:attributes])
      end

      private

      def self.my_programs
        @my_programs ||= begin
          response = HackerOne::Client::Api.hackerone_api_connection.get do |req|
            req.url "me/programs"
          end

          data = HackerOne::Client::Api.parse_response(response)
          data.map { |program| self.new(program) }
        end
      end
    end
  end
end
