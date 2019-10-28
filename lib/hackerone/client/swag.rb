module HackerOne
  module Client
    class Swag
      include ResourceHelper
      delegate :sent, :created_at, to: :attributes

      def initialize(swag, program = nil)
        @swag = swag
        @program = program
      end

      def id
        @swag[:id]
      end

      def sent?
        !!attributes.sent
      end

      def user
        if user_relationship = relationships[:user]
          HackerOne::Client::User.new(user_relationship[:data])
        end
      end

      def address
        if address_relationship = relationships[:address]
          HackerOne::Client::Address.new(address_relationship[:data])
        end
      end

      def mark_as_sent!
        body = {
          type: "swag",
          attributes: {
            sent: true
          }
        }

        response_json = make_put_request("programs/#{@program.id}/swag/#{id}", request_body: body)
        self.class.new(response_json, @program)
      end

      private

      def attributes
        OpenStruct.new(@swag[:attributes])
      end

      def relationships
        @swag[:relationships]
      end
    end
  end
end
