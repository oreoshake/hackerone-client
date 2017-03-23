module HackerOne
  module Client
    module Activities
      class Activity
        delegate :message, :created_at, :updated_at, to: :attributes
        delegate :actor, to: :relationships

        def initialize(activity)
          @activity = OpenStruct.new activity
        end

        def internal?
          attributes.internal
        end

        private

        def relationships
          OpenStruct.new(activity.relationships)
        end

        def attributes
          OpenStruct.new(activity.attributes)
        end

        attr_reader :activity
      end

      class BountyAwarded < Activity
        delegate :bounty_amount, to: :attributes
        delegate :bonus_amount, to: :attributes
      end

      class SwagAwarded < Activity
        delegate :swag, to: :relationships
      end

      class UserAssignedToBug < Activity
        delegate :assigned_user, to: :relationships
      end

      class BugTriaged < Activity
      end

      class ReferenceIdAdded < Activity
        delegate :reference, :reference_url, to: :attributes
      end

      ACTIVITY_TYPE_CLASS_MAPPING = {
        'activity-bounty-awarded' => BountyAwarded,
        'activity-swag-awarded' => SwagAwarded,
        'activity-user-assigned-to-bug' => UserAssignedToBug,
        'activity-bug-triaged' => BugTriaged,
        'activity-reference-id-added' => ReferenceIdAdded
      }.freeze

      def self.build(activity_data)
        activity_type_class = ACTIVITY_TYPE_CLASS_MAPPING.fetch \
          activity_data[:type], Activity

        # puts activity_data
        activity_type_class.new activity_data
      end
    end
  end
end
