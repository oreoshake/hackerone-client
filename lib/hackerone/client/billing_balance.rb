# frozen_string_literal: true

module HackerOne
  module Client
    class BillingBalance
      delegate :balance, to: :attributes

      def initialize(billing_balance)
        @billing_balance = OpenStruct.new billing_balance
      end

      private
      def attributes
        OpenStruct.new(@billing_balance[:attributes])
      end
    end
  end
end
