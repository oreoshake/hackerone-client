module HackerOne
  module Client
    class User
      include ResourceHelper

      delegate :username, to: :attributes

      def self.find(username_we_want)
        make_get_request("users/#{username_we_want}")
      end

      def initialize(user)
        @user = user
      end

      def id
        @user[:id]
      end

      private

      def attributes
        OpenStruct.new(@user[:attributes])
      end
    end
  end
end
