# frozen_string_literal: true

module HackerOne
  module Client
    class Member
      delegate :permissions, to: :attributes

      def initialize(member)
        @member = member
      end

      def user
        @user ||= User.new(relationships.user[:data])
      end

      def id
        @member[:id]
      end

      private

      def attributes
        OpenStruct.new(@member[:attributes])
      end

      def relationships
        OpenStruct.new(@member[:relationships])
      end
    end
  end
end
