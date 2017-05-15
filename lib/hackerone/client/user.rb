module HackerOne
  module Client
    class User
      delegate :username, to: :attributes

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
