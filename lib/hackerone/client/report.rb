# frozen_string_literal: true

require_relative "./resource_helper"
require_relative "./weakness"
require_relative "./activity"

module HackerOne
  module Client
    class Report
      include ResourceHelper

      STATES = %w(
        new
        triaged
        needs-more-info
        resolved
        not-applicable
        informative
        duplicate
        spam
      ).map(&:to_sym).freeze

      STATES_REQUIRING_STATE_CHANGE_MESSAGE = %w(
        needs-more-info
        informative
        duplicate
      ).map(&:to_sym).freeze

      SEVERITY_RATINGS = %w(
        none
        low
        medium
        high
        critical
      ).freeze

      class << self
        def add_on_state_change_hook(proc)
          on_state_change_hooks << proc
        end

        def clear_on_state_change_hooks
          @on_state_change_hooks = []
        end

        def on_state_change_hooks
          @on_state_change_hooks ||= []
        end
      end

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

      def issue_tracker_reference_id
        attributes[:issue_tracker_reference_id]
      end

      def severity
        attributes[:severity]
      end

      def state
        attributes[:state]
      end

      def reporter
        relationships
          .fetch(:reporter, {})
          .fetch(:data, {})
          .fetch(:attributes, {})
      end

      def assignee
        if assignee_relationship = relationships[:assignee]
          HackerOne::Client::User.new(assignee_relationship[:data])
        else
          nil
        end
      end

      def payment_total
        payments.reduce(0) { |total, payment| total + payment_amount(payment) }
      end

      def structured_scope
        StructuredScope.new(relationships[:structured_scope].fetch(:data, {}))
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
        @weakness ||= Weakness.new(relationships.fetch(:weakness, {}).fetch(:data, {}).fetch(:attributes, {}))
      end

      def classification_label
        weakness.to_owasp
      end

      # Bounty writeups just use the key, and not the label value.
      def writeup_classification
        classification_label.split("-").first
      end

      def activities
        if ships = relationships.fetch(:activities, {}).fetch(:data, [])
          ships.map do |activity_data|
            Activities.build(activity_data)
          end
        end
      end

      def program
        @program || Program.find(relationships[:program][:data][:attributes][:handle])
      end

      def award_bounty(message:, amount:, bonus_amount: nil)
        request_body = {
          message: message,
          amount: amount,
          bonus_amount: bonus_amount
        }

        response_body = make_post_request(
          "reports/#{id}/bounties",
          request_body: request_body
        )
        Bounty.new(response_body)
      end

      def award_swag(message:)
        request_body = {
          message: message
        }

        response_body = make_post_request(
          "reports/#{id}/swags",
          request_body: request_body
        )
        Swag.new(response_body, program)
      end

      def update_severity(rating:)
        raise ArgumentError, "Invalid severity rating" unless SEVERITY_RATINGS.include?(rating)

        request_body = {
          type: "severity",
          attributes: {
            rating: rating
          }
        }
        response_body = make_post_request(
          "reports/#{id}/severities",
          request_body: request_body
        )
        @report[:attributes][:severity] = { rating: rating }
        Activities.build(response_body)
      end

      def suggest_bounty(message:, amount:, bonus_amount: nil)
        request_body = {
          message: message,
          amount: amount,
          bonus_amount: bonus_amount
        }

        response_body = make_post_request(
          "reports/#{id}/bounty_suggestions",
          request_body: request_body
        )
        Activities.build(response_body)
      end

      ## Idempotent: change the state of a report. See STATES for valid values.
      #
      # id: the ID of the report
      # state: the state in which the report is to be put in
      #
      # returns an HackerOne::Client::Report object or raises an error if
      # no report is found.
      def state_change(state, message = nil, attributes = {})
        raise ArgumentError, "state (#{state}) must be one of #{STATES}" unless STATES.include?(state)

        old_state = self.state
        body = {
          type: "state-change",
          attributes: {
            state: state
          }
        }

        body[:attributes] = body[:attributes].reverse_merge(attributes)

        if message
          body[:attributes][:message] = message
        elsif STATES_REQUIRING_STATE_CHANGE_MESSAGE.include?(state)
          fail ArgumentError, "State #{state} requires a message. No message was supplied."
        else
          # message is in theory optional, but a value appears to be required.
          body[:attributes][:message] = ""
        end
        response_json = make_post_request("reports/#{id}/state_changes", request_body: body)
        @report = response_json
        self.class.on_state_change_hooks.each do |hook|
          hook.call(self, old_state.to_s, state.to_s)
        end
        self
      end

      ## Idempotent: Add a report reference to a project
      #
      # id: the ID of the report
      # state: value for the reference (e.g. issue number or relative path to cross-repo issue)
      #
      # returns an HackerOne::Client::Report object or raises an error if
      # no report is found.
      def add_report_reference(reference)
        body = {
          type: "issue-tracker-reference-id",
          attributes: {
            reference: reference
          }
        }

        response_json = make_post_request("reports/#{id}/issue_tracker_reference_id", request_body: body)
        @report = response_json[:relationships][:report][:data]
        self
      end

      ## Idempotent: add the issue reference and put the report into the "triage" state.
      #
      # id: the ID of the report
      # state: value for the reference (e.g. issue number or relative path to cross-repo issue)
      #
      # returns an HackerOne::Client::Report object or raises an error if
      # no report is found.
      def triage(reference)
        add_report_reference(reference)
        state_change(:triaged)
      end

      # Add a comment to a report. By default, internal comments will be added.
      #
      # id: the ID of the report
      # message: the content of the comment that will be created
      # internal: "team only" comment (true, default) or "all participants"
      def add_comment(message, internal: true)
        fail ArgumentError, "message is required" if message.blank?

        body = {
          type: "activity-comment",
          attributes: {
            message: message,
            internal: internal
          }
        }

        response_json = make_post_request("reports/#{id}/activities", request_body: body)
        HackerOne::Client::Activities.build(response_json)
      end

      def assign_to_user(name)
        member = program.find_member(name)
        _assign_to(member.user.id, :user)
      end

      def assign_to_group(name)
        group = program.find_group(name)
        _assign_to(group.id, :group)
      end

      def unassign
        _assign_to(nil, :nobody)
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

      def _assign_to(assignee_id, assignee_type)
        request_body = {
          type: assignee_type,
        }
        request_body[:id] = assignee_id if assignee_id

        response = HackerOne::Client::Api.hackerone_api_connection.put do |req|
          req.headers["Content-Type"] = "application/json"
          req.url "reports/#{id}/assignee"
          req.body = { data: request_body }.to_json
        end
        unless response.success?
          fail("Unable to assign report #{id} to #{assignee_type} with id '#{assignee_id}'. Response status: #{response.status}, body: #{response.body}")
        end

        @report = parse_response response
      end
    end
  end
end
