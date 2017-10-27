require_relative './resource_helper'

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

      def attributes
        OpenStruct.new(@program[:attributes])
      end
       # List all groups, membership types and users for a program
      def users()
        make_get_request(
          "programs/#{id}"
          )
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
      
      # Get reporters via pages.
       def reporters(page_number: 1, page_size: 25)
        make_get_request(
          "programs/#{id}/reporters",
          params: { page: { number: page_number, size: page_size } }
        )
      end

      def common_responses(page_number: 1, page_size: 100)
        make_get_request(
          "programs/#{id}/common_responses",
          params: { page: { number: page_number, size: page_size } }
        )
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
