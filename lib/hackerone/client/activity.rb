# frozen_string_literal: true

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

        def attachments
          @attachments ||= activity.relationships.fetch(:attachments, {})
              .fetch(:data, [])
              .map { |attachment| HackerOne::Client::Attachment.new(attachment) }
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
          if ENV[HackerOne::Client::LENIENT_MODE_ENV_VARIABLE]
            Float(formatted_bounty_amount) rescue 0
          else
            begin
              Float(formatted_bounty_amount)
            rescue ArgumentError
              raise ArgumentError.new("Improperly formatted bounty amount")
            end
          end
        end

        def bonus_amount
          formatted_bonus_amount = attributes.bonus_amount || "0"
          if ENV[HackerOne::Client::LENIENT_MODE_ENV_VARIABLE]
            Float(formatted_bonus_amount) rescue 0
          else
            begin
              Float(formatted_bonus_amount)
            rescue ArgumentError
              raise ArgumentError.new("Improperly formatted bonus amount")
            end
          end
        end
      end

      class SwagAwarded < Activity
        delegate :swag, to: :relationships
      end

      class UserAssignedToBug < Activity
        delegate :assigned_user, to: :relationships
      end

      class GroupAssignedToBug < Activity
        def group
          HackerOne::Client::Group.new(relationships.group[:data])
        end
      end

      class BugTriaged < Activity
      end

      class ReferenceIdAdded < Activity
        delegate :reference, :reference_url, to: :attributes
      end

      class CommentAdded < Activity
        delegate :message, :internal, to: :attributes
      end

      class BountySuggested < Activity
        delegate :message, :bounty_amount, :bonus_amount, to: :attributes
      end

      class ReportLocked < Activity
      end

      ACTIVITY_TYPE_CLASS_MAPPING = {
        "activity-bounty-awarded" => BountyAwarded,
        "activity-swag-awarded" => SwagAwarded,
        "activity-user-assigned-to-bug" => UserAssignedToBug,
        "activity-group-assigned-to-bug" => GroupAssignedToBug,
        "activity-bug-triaged" => BugTriaged,
        "activity-reference-id-added" => ReferenceIdAdded,
        "activity-comment" => CommentAdded,
        "activity-bounty-suggested" => BountySuggested,
        "activity-comments-closed" => ReportLocked
      }.freeze

      def self.build(activity_data)
        activity_type_class = ACTIVITY_TYPE_CLASS_MAPPING.fetch \
          activity_data[:type], Activity

        activity_type_class.new activity_data
      end
    end
  end
end
