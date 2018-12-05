module HackerOne
  module Client
    module Incremental
      class Activities
        include ResourceHelper

        attr_reader :program, :updated_at_after, :page_size

        def initialize(program, updated_at_after: nil, page_size: 25)
          @program = program
          @updated_at_after = updated_at_after
          @page_size = page_size
        end

        def traverse
          loop do
            activities.each do |activity|
              yield activity
            end

            break if next_page.nil?
          end
        end

        def activities
          @activities ||= current_page[:data].map do |activity_json|
            HackerOne::Client::Activities.build activity_json
          end
        end

        def next_page
          return nil unless next_cursor.present?

          # Set cursor to next page
          @updated_at_after = next_cursor

          # Remove memoization
          @current_page = nil
          @activities = nil

          # Fetch new page
          current_page

          activities
        end

        private

        def current_page
          @current_page ||= make_get_request(
            'incremental/activities',
            extract_data: false,
            params: {
              handle: program.handle,
              page: { size: page_size },
              updated_at_after: updated_at_after
            }
          )
        end

        def next_cursor
          current_page[:meta][:max_updated_at]
        end
      end
    end
  end
end
