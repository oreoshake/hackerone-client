require "faraday"
require "json"
require "active_support/time"
require_relative "client/version"
require_relative "client/report"
require_relative "client/activity"
require_relative "client/program"
require_relative "client/reporter"
require_relative "client/member"
require_relative "client/user"
require_relative "client/group"
require_relative "client/structured_scope"
require_relative "client/swag"
require_relative "client/address"
require_relative "client/bounty"
require_relative "client/incremental/activities"

module HackerOne
  module Client
    class NotConfiguredError < StandardError; end

    DEFAULT_LOW_RANGE = 1...999
    DEFAULT_MEDIUM_RANGE = 1000...2499
    DEFAULT_HIGH_RANGE = 2500...4999
    DEFAULT_CRITICAL_RANGE = 5000...100_000_000

    LENIENT_MODE_ENV_VARIABLE = 'HACKERONE_CLIENT_LENIENT_MODE'

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

      def reporters
        raise ArgumentError, "Program cannot be nil" unless program
        response = self.class.hackerone_api_connection.get do |req|
          req.url "programs/#{Program.find(program).id}/reporters"
        end

        data = self.class.parse_response(response)
        if data.nil?
          raise RuntimeError, "Expected data attribute in response: #{response.body}"
        end

        data.map do |reporter|
          Reporter.new(reporter)
        end
      end

      ## Returns all open reports, optionally with a time bound
      #
      # program: the HackerOne program to search on (configure globally with Hackerone::Client.program=)
      # since (optional): a time bound, don't include reports earlier than +since+. Must be a DateTime object.
      #
      # returns all open reports or an empty array
      def reports(since: 3.days.ago)
        raise ArgumentError, "Program cannot be nil" unless program
        response = self.class.hackerone_api_connection.get do |req|
          options = {
            "filter[state][]" => "new",
            "filter[program][]" => program,
            "filter[created_at__gt]" => since.iso8601
          }
          req.url "reports", options
        end

        data = self.class.parse_response(response)

        data.map do |report|
          Report.new(report)
        end
      end

      ## Public: retrieve a report
      #
      # id: the ID of a specific report
      #
      # returns an HackerOne::Client::Report object or raises an error if
      # no report is found.
      def report(id)
        Report.new(get("reports/#{id}"))
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

        self.class.parse_response(response)
      end

      def get(endpoint, params = nil)
        response = with_retry do
          self.class.hackerone_api_connection.get do |req|
            req.headers['Content-Type'] = 'application/json'
            req.params = params || {}
            req.url endpoint
          end
        end

        self.class.parse_response(response)
      end

      def self.parse_response(response, extract_data: true)
        if response.status.to_s.start_with?("4")
          raise ArgumentError, "API called failed, probably your fault: #{response.body}"
        elsif response.status.to_s.start_with?("5")
          raise RuntimeError, "API called failed, probably their fault: #{response.body}"
        elsif response.success?
          response_body_json = JSON.parse(response.body, :symbolize_names => true)
          if extract_data && response_body_json.key?(:data)
            response_body_json[:data]
          else
            response_body_json
          end
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
