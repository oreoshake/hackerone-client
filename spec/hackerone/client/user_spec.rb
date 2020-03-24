# frozen_string_literal: true

require "spec_helper"

RSpec.describe HackerOne::Client::User do
  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "bar"
  end

  describe "find" do
    it "returns a user" do
      user = VCR.use_cassette(:user_find_fransrosen) do
        described_class.find "fransrosen"
      end

      expect(user.reputation).to eq 15033
      expect(user.signal).to be_within(0.1).of(6.4)
      expect(user.impact).to be_within(0.1).of(22.6)
      expect(user.username).to eq "fransrosen"
    end
  end
end
