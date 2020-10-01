# frozen_string_literal: true

require "spec_helper"

RSpec.describe HackerOne::Client::Address do
  let (:address_data) do
     {
      name: "Brian Anglin",
      street: " 88 Colin P Kelly Jr Street",
      city: "San Francisco",
      postal_code: "94107",
      state: "California",
      country: "United States",
      created_at: "2019-10-21T20:50:40.159Z",
      tshirt_size: "M_Medium",
      phone_number: "555-555-5555"
    }
  end

  let(:example) do
    {
      id: "7374",
      type: "address",
      attributes:  address_data,
    }.with_indifferent_access
  end

  it "creates the address type with attributes" do
    address = HackerOne::Client::Address.new example
    expect(address.class).to eq described_class
    expect(address.id).to eq "7374"

    address_data.keys.each do |key|
      expect(address.send key.to_s).to eq address_data[key]
    end
  end
end
