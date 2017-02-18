require "faraday"
require 'active_support/time'
require_relative "client/version"
require_relative "client/report"

module HackerOne
  module Client
    class NotConfiguredError < StandardError; end

    class << self
      attr_accessor :program
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

        data = JSON.parse(response.body, :symbolize_names => true)[:data]
        if data.nil?
          raise RuntimeError, "Expected data attribute in response: #{response.body}"
        end

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
        response = with_retry do
          self.class.hackerone_api_connection.get do |req|
            req.url "reports/#{id}"
          end
        end

        if response.success?
          Report.new(JSON.parse(response.body, :symbolize_names => true)[:data])
        else
          raise ArgumentError, "Could not retrieve HackerOne report ##{id}: #{response.body}"
        end
      end

      private
      def self.hackerone_api_connection
        @connection ||= Faraday.new(:url => "https://api.hackerone.com/v1") do |faraday|
          unless ENV["HACKERONE_TOKEN_NAME"] && ENV["HACKERONE_TOKEN"]
            raise NotConfiguredError, "HACKERONE_TOKEN_NAME HACKERONE_TOKEN environment variables must be set"
          end

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
