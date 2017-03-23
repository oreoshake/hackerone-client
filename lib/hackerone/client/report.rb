require_relative './weakness'
require_relative './activity'

module HackerOne
  module Client
    class Report
      def initialize(report)
        @report = report
      end

      def id
        @report[:id]
      end

      def title
        attributes[:title]
      end

      def created_at
        attributes[:created_at]
      end

      def issue_tracker_reference_url
        attributes[:issue_tracker_reference_url]
      end

      def reporter
        relationships
          .fetch(:reporter, {})
          .fetch(:data, {})
          .fetch(:attributes, {})
      end

      def payment_total
        payments.reduce(0) { |total, payment| total + payment_amount(payment) }
      end

      # Excludes reports where the payout amount is 0 indicating swag-only or no
      # payout for the issue supplied
      def risk
        case payment_total
        when HackerOne::Client.low_range || DEFAULT_LOW_RANGE
          "low"
        when HackerOne::Client.medium_range || DEFAULT_MEDIUM_RANGE
          "medium"
        when HackerOne::Client.high_range || DEFAULT_HIGH_RANGE
          "high"
        when HackerOne::Client.critical_range || DEFAULT_CRITICAL_RANGE
          "critical"
        end
      end

      def summary
        attributes[:vulnerability_information]
      end

      def weakness
        @weakness ||= Weakness.new relationships[:weakness][:data][:attributes]
      end

      def classification_label
        weakness.to_owasp
      end

      # Bounty writeups just use the key, and not the label value.
      def writeup_classification
        classification_label().split("-").first
      end

      def activities
        relationships.dig(:activities, :data)&.map do |activity_data|
          Activities.build(activity_data)
        end
      end

      private

      def payments
        activities.select { |activity| activity.is_a? Activities::BountyAwarded }
      end

      def payment_amount(payment)
        payment.bounty_amount
      end

      def attributes
        @report[:attributes]
      end

      def relationships
        @report[:relationships]
      end

      def vulnerability_types
        relationships.fetch(:vulnerability_types, {}).fetch(:data, [])
      end
    end
  end
end
