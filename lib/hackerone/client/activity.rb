module HackerOne
  module Client
    module Activities
      BOUNTY_AWARDED_ACTIVITY_KEY = "activity-bounty-awarded"
      SWAG_AWARDED_ACTIVITY_KEY = "activity-swag-awarded"

      class Activity
        delegate :message, :created_at, :updated_at, to: :attributes

        def initialize(activity)
          @activity = OpenStruct.new activity
        end

        def internal?
          attributes.internal
        end

        private

        def attributes
          OpenStruct.new(activity.attributes)
        end

        attr_reader :activity
      end

      class BountyAwarded < Activity
        delegate :bounty_amount, to: :attributes
      end

      class SwagAwarded < Activity
      end

      def self.build(activity_data)
        activity_type_class_mapping = {
          BOUNTY_AWARDED_ACTIVITY_KEY => BountyAwarded,
          SWAG_AWARDED_ACTIVITY_KEY => SwagAwarded
        }

        activity_type_class = \
          activity_type_class_mapping.fetch(activity_data[:type], Activity)

        activity_type_class.new activity_data
      end
    end
  end
end
