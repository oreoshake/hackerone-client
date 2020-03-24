# frozen_string_literal: true

module HackerOne
  module Client
    class Address
      delegate :name, :street, :city, :postal_code, :state, :country, \
        :created_at, :tshirt_size, :phone_number, to: :attributes

      def initialize(address)
        @address = address
      end

      def id
        @address[:id]
      end

      private

      def attributes
        OpenStruct.new(@address[:attributes])
      end
    end
  end
end
