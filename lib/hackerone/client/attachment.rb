# frozen_string_literal: true

module HackerOne
  module Client
    class Attachment
      delegate :expiring_url, :file_name, :content_type, :created_at, \
        :file_size, to: :attributes

      def initialize(attachment)
        @attachment = attachment
      end

      def id
        @attachment[:id]
      end

      private

      def attributes
        OpenStruct.new(@attachment[:attributes])
      end
    end
  end
end
