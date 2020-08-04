# frozen_string_literal: true

require "spec_helper"
require "active_support/core_ext/hash"

RSpec.describe HackerOne::Client::Attachment do
  let (:attachment_data) do
    {
      expiring_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      created_at: "2016-02-02T04:05:06.000Z",
      file_name: "root.rb",
      content_type: "image/jpeg",
      file_size: 2871
    }
  end

  let(:example) do
    {
      id: "1337",
      type: "attachment",
      attributes: attachment_data,
    }.with_indifferent_access
  end

  it "creates the address type with attributes" do
    attachment = HackerOne::Client::Attachment.new example
    expect(attachment.class).to eq described_class
    expect(attachment.id).to eq "1337"

    attachment_data.keys.each do |key|
      expect(attachment.send key.to_s).to eq attachment_data[key]
    end
  end
end
