# frozen_string_literal: true

require_relative "./resource_helper"

module HackerOne
  module Client
    class Program
      include ResourceHelper

      delegate :handle, to: :attributes

      def self.find(program_handle_we_want)
        my_programs.find do |program|
          program.handle == program_handle_we_want
        end
      end

      def initialize(program)
        @program = program
      end

      def id
        @program[:id]
      end

      def incremental_activities(updated_at_after: nil, page_size: 25)
        HackerOne::Client::Incremental::Activities.new(
          self,
          updated_at_after: updated_at_after,
          page_size: page_size
        )
      end

      def attributes
        OpenStruct.new(@program[:attributes])
      end

      def member?(username)
        find_member(username).present?
      end

      def group?(groupname)
        find_group(groupname).present?
      end

      def find_member(username)
        members.find { |member| member.user.username == username }
      end

      def find_group(groupname)
        groups.find { |group| group.name == groupname }
      end

      def update_policy(policy:)
        body = {
          type: "program-policy",
          attributes: {
            policy: policy
          }
        }
        make_put_request("programs/#{id}/policy", request_body: body)
      end

      def common_responses(page_number: 1, page_size: 100)
        make_get_request(
          "programs/#{id}/common_responses",
          params: { page: { number: page_number, size: page_size } }
        )
      end

      def swag(page_number: 1, page_size: 100)
        response_body = make_get_request(
          "programs/#{id}/swag",
          params: { page: { number: page_number, size: page_size } }
        )
        response_body.map { |r| Swag.new(r, self) }
      end

      private

      def members
        @members ||= relationships.members[:data].map { |member_data| Member.new(member_data) }
      end

      def groups
        @groups ||= relationships.groups[:data].map { |group_data| Group.new(group_data) }
      end

      def relationships
        # Relationships are only included in the /programs/:id call,
        # which is why we need to do a separate call here.
        @relationships ||= begin
          response = HackerOne::Client::Api.hackerone_api_connection.get do |req|
            req.url "programs/#{id}"
          end

          data = HackerOne::Client::Api.parse_response(response)
          OpenStruct.new(data[:relationships])
        end
      end

      def self.my_programs
        @my_programs ||= begin
          response = HackerOne::Client::Api.hackerone_api_connection.get do |req|
            req.url "me/programs"
          end

          data = HackerOne::Client::Api.parse_response(response)
          data.map { |program| self.new(program) }
        end
      end
    end
  end
end
