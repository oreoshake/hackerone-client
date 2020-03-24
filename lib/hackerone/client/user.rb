# frozen_string_literal: true

module HackerOne
  module Client
    class User
      include ResourceHelper

      delegate :username, :signal, :impact, :reputation, to: :attributes

      def self.find(username_we_want)
        user_json = make_get_request("users/#{username_we_want}")
        new(user_json)
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
