require "pry"

module HackerOne
  module Client
    class Report
      PAYOUT_ACTIVITY_KEY = "activity-bounty-awarded"
      CLASSIFICATION_MAPPING = {
        "None Applicable" => "A0-Other",
        "Denial of Service" => "A0-Other",
        "Memory Corruption" => "A0-Other",
        "Cryptographic Issue" => "A0-Other",
        "Privilege Escalation" => "A0-Other",
        "UI Redressing (Clickjacking)" => "A0-Other",
        "Command Injection" => "A1-Injection",
        "Remote Code Execution" => "A1-Injection",
        "SQL Injection" => "A1-Injection",
        "Authentication" => "A2-AuthSession",
        "Cross-Site Scripting (XSS)" => "A3-XSS",
        "Information Disclosure" => "A6-DataExposure",
        "Cross-Site Request Forgery (CSRF)" => "A8-CSRF",
        "Unvalidated / Open Redirect" => "A10-Redirects"
      }

      def initialize(report)
        @report = report
      end

      def id
        @report[:id]
      end

      def title
        attributes[:title]
      end

      def vulnerability_information
        attributes[:vulnerability_information]
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
        @risk ||= begin
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
      end

      def summary
        summaries = relationships.fetch(:summaries, {}).fetch(:data, []).select {|summary| summary[:type] == "report-summary" }
        return unless summaries

        summaries.select { |summary| summary[:attributes][:category] == "team" }.map do |summary|
          summary[:attributes][:content]
        end.join("\n")
      end

      # Do our best to map the value that hackerone provides and the reporter sets
      # to the OWASP Top 10. Take the first match since multiple values can be set.
      # This is used for the issue label.
      def classification_label
        owasp_mapping = vulnerability_types.map do |vuln_type|
          CLASSIFICATION_MAPPING[vuln_type[:attributes][:name]]
        end.flatten.first

        owasp_mapping || CLASSIFICATION_MAPPING["None Applicable"]
      end

      # Bounty writeups just use the key, and not the label value.
      def writeup_classification
        classification_label().split("-").first
      end

      private
      def payments
        activities.select { |activity| activity[:type] == PAYOUT_ACTIVITY_KEY }
      end
      
      def payment_amount(payment)
        @payment_amount ||= payment.fetch(:attributes, {}).fetch(:bounty_amount, 0).gsub(/[^\d]/, "").to_i
      end

      def activities
        relationships.fetch(:activities, {}).fetch(:data, [])
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
