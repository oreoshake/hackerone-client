module HackerOne
  module Client
    class Bounty
      delegate(
        :amount,
        :bonus_amount,
        :awarded_amount,
        :awarded_bonus_amount,
        :awarded_currency,
        to: :attributes
      )

      def initialize(bounty)
        @bounty = bounty
      end

      def id
        @bounty[:id]
      end

      private

      def attributes
        OpenStruct.new(@bounty[:attributes])
      end
    end
  end
end
