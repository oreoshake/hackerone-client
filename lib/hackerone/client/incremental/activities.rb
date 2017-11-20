module HackerOne
  module Client
    module Incremental
      class Activities
        include ResourceHelper

        DOTFILE = '.hackerone_client_incremental_activities'.freeze

        attr_reader :program, :updated_at_after, :page_size

        def initialize(program, updated_at_after: nil, page_size: 25)
          @program = program
          @updated_at_after = updated_at_after
          @page_size = page_size
        end

        def loop_through_activities
          load_dotfile

          loop do
            fetch_current_page

            activities.each do |activity_json|
              activity = HackerOne::Client::Activities
                         .build(activity_json)
              yield activity
            end

            break if next_page.nil?
          end
        end

        def activities
          current_page[:data]
        end

        def next_page?
          next_updated_at_after.present?
        end

        def next_page
          return nil unless next_page?

          @updated_at_after = next_updated_at_after
          fetch_current_page
        end

        def load_dotfile
          return nil unless File.exist?(dotfile_filepath)
          dotfile_content = JSON.parse(
            File.read(dotfile_filepath)
          )
          @updated_at_after = dotfile_content
                              .fetch(program.handle)
                              .fetch('updated_at_after')
        end

        def store_dotfile
          new_dotfile_content = {
            program.handle => {
              updated_at_after: updated_at_after
            }
          }
          File.open(dotfile_filepath, 'w') do |f|
            f.puts(JSON.pretty_generate(new_dotfile_content))
          end
        end

        private

        def fetch_current_page
          @current_page = nil
          current_page
        end

        def current_page
          @current_page ||= make_get_request(
            'incremental/activities',
            extract_data: false,
            params: {
              handle: program.handle,
              first: page_size,
              updated_at_after: updated_at_after
            }
          )
        end

        def dotfile_filepath
          File.join(Dir.home, DOTFILE)
        end

        def next_updated_at_after
          current_page[:meta][:max_updated_at]
        end
      end
    end
  end
end
