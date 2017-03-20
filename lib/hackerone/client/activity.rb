module HackerOne
  module Client
    class Activity
      PAYOUT_ACTIVITY_KEY = "activity-bounty-awarded"

      delegate :bounty_amount, to: :attributes

      def initialize(activity)
        @activity = OpenStruct.new(activity)
      end

      def payout?
        activity.type == PAYOUT_ACTIVITY_KEY
      end

      private

      def attributes
        OpenStruct.new(activity.attributes)
      end

      attr_reader :activity
    end
  end
end
