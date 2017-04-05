require "faraday"
require 'active_support/time'
require_relative "client/version"
require_relative "client/report"
require_relative "client/activity"

module HackerOne
  module Client
    class NotConfiguredError < StandardError; end

    DEFAULT_LOW_RANGE = 1...999
    DEFAULT_MEDIUM_RANGE = 1000...2499
    DEFAULT_HIGH_RANGE = 2500...4999
    DEFAULT_CRITICAL_RANGE = 5000...100_000_000

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

    class << self
      ATTRS = [:low_range, :medium_range, :high_range, :critical_range].freeze
      attr_accessor :program
      attr_reader *ATTRS

      ATTRS.each do |attr|
        define_method "#{attr}=" do |value|
          raise ArgumentError, "value must be a range object" unless value.is_a?(Range)
          instance_variable_set :"@#{attr}", value
        end
      end
    end

    class Api
      def initialize(program = nil)
        @program = program
      end

      def program
        @program || HackerOne::Client.program
      end

      ## Returns all open reports, optionally with a time bound
      #
      # program: the HackerOne program to search on (configure globally with Hackerone::Client.program=)
      # since (optional): a time bound, don't include reports earlier than +since+. Must be a DateTime object.
      # state (optional): state or array of states to filter on (defaults to 'new' reports). Specify state: :all to includes all states.
      # page_number (optional): which page of the current query should be returned
      #
      # returns all open reports or an empty array
      def reports(since: 3.days.ago, state: :new, page_number: 0, page_size: PAGE_SIZE)
        raise ArgumentError, "Program cannot be nil" unless program
        if state != :all && !STATES.include?(state)
          raise ArgumentError, "'state' must be :all or one of #{STATES}"
        end

        response = self.class.hackerone_api_connection.get do |req|
          options = {
            "page[size]" => page_size,
            "page[number]" => page_number,
            "filter[program][]" => program,
            "filter[created_at__gt]" => since.iso8601,
          }

          unless state == :all
            options["filter[state][]"] = state
          end
          req.url "reports", options
        end

        parsed_response = JSON.parse(response.body, :symbolize_names => true)
        unless data = parsed_response[:data]
          raise RuntimeError, "Expected data attribute in response: #{response.body}"
        end

        reports = data.map do |report|
          Report.new(report)
        end

        if parsed_response[:links][:next]
          reports + reports(since: since, state: state, page_number: page_number + 1)
        else
          reports
        end
      end

      ## Idempotent: add the issue reference and put the report into the "triage" state.
      #
      # id: the ID of the report
      # state: value for the reference (e.g. issue number or relative path to cross-repo issue)
      #
      # returns an HackerOne::Client::Report object or raises an error if
      # no report is found.
      def triage(id, reference)
        add_report_reference(id, reference)
        state_change(id, :triaged)
      end

      ## Idempotent: Add a report reference to a project
      #
      # id: the ID of the report
      # state: value for the reference (e.g. issue number or relative path to cross-repo issue)
      #
      # returns an HackerOne::Client::Report object or raises an error if
      # no report is found.
      def add_report_reference(id, reference)
        body = {
          data: {
            type: "issue-tracker-reference-id",
            attributes: {
              reference: reference
            }
          }
        }

        post("reports/#{id}/issue_tracker_reference_id", body)
      end

      ## Idempotent: change the state of a report. See STATES for valid values.
      #
      # id: the ID of the report
      # state: the state in which the report is to be put in
      #
      # returns an HackerOne::Client::Report object or raises an error if
      # no report is found.
      def state_change(id, state, message = nil)
        raise ArgumentError, "state (#{state}) must be one of #{STATES}" unless STATES.include?(state)

        body = {
          data: {
            type: "state-change",
            attributes: {
              state: state
            }
          }
        }

        if message
          body[:data][:attributes][:message] = message
        elsif STATES_REQUIRING_STATE_CHANGE_MESSAGE.include?(state)
          fail ArgumentError, "State #{state} requires a message. No message was supplied."
        else
          # message is in theory optional, but a value appears to be required.
          body[:data][:attributes][:message] = ""
        end
        post("reports/#{id}/state_changes", body)
      end

      ## Public: retrieve a report
      #
      # id: the ID of a specific report
      #
      # returns an HackerOne::Client::Report object or raises an error if
      # no report is found.
      def report(id)
        get("reports/#{id}")
      end

      private
      def post(endpoint, body)
        response = with_retry do
          self.class.hackerone_api_connection.post do |req|
            req.headers['Content-Type'] = 'application/json'
            req.body = body.to_json
            req.url endpoint
          end
        end

        parse_response(response)
      end

      def get(endpoint, params = nil)
        response = with_retry do
          self.class.hackerone_api_connection.get do |req|
            req.headers['Content-Type'] = 'application/json'
            req.params = params || {}
            req.url endpoint
          end
        end

        parse_response(response)
      end

      def parse_response(response)
        if response.status.to_s.start_with?("4")
          raise ArgumentError, "API called failed, probably your fault: #{response.body}"
        elsif response.status.to_s.start_with?("5")
          raise RuntimeError, "API called failed, probably their fault: #{response.body}"
        elsif response.success?
          Report.new(JSON.parse(response.body, :symbolize_names => true)[:data])
        else
          raise RuntimeError, "Not sure what to do here: #{response.body}"
        end
      end

      def self.hackerone_api_connection
        unless ENV["HACKERONE_TOKEN_NAME"] && ENV["HACKERONE_TOKEN"]
          raise NotConfiguredError, "HACKERONE_TOKEN_NAME HACKERONE_TOKEN environment variables must be set"
        end

        @connection ||= Faraday.new(:url => "https://api.hackerone.com/v1") do |faraday|
          faraday.basic_auth(ENV["HACKERONE_TOKEN_NAME"], ENV["HACKERONE_TOKEN"])
          faraday.adapter Faraday.default_adapter
        end
      end

      def with_retry(attempts=3, &block)
        attempts_remaining = attempts

        begin
          yield
        rescue StandardError
          if attempts_remaining > 0
            attempts_remaining -= 1
            sleep (attempts - attempts_remaining)
            retry
          else
            raise
          end
        end
      end
    end
  end
end
