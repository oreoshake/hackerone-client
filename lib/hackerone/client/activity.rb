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
        def bounty_amount
          formatted_bounty_amount = attributes.bounty_amount || "0"
          formatted_bounty_amount.gsub(/[^\d]/, "").to_i
        end

        def bonus_amount
          formatted_bonus_amount = attributes.bonus_amount || "0"
          formatted_bonus_amount.gsub(/[^\d]/, "").to_i
        end
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

      class CommentAdded < Activity
        delegate :message, :internal, to: :attributes
      end

      ACTIVITY_TYPE_CLASS_MAPPING = {
        'activity-bounty-awarded' => BountyAwarded,
        'activity-swag-awarded' => SwagAwarded,
        'activity-user-assigned-to-bug' => UserAssignedToBug,
        'activity-bug-triaged' => BugTriaged,
        'activity-reference-id-added' => ReferenceIdAdded,
        'activity-comment' => CommentAdded
      }.freeze

      def self.build(activity_data)
        activity_type_class = ACTIVITY_TYPE_CLASS_MAPPING.fetch \
          activity_data[:type], Activity

        activity_type_class.new activity_data
      end
    end
  end
end
