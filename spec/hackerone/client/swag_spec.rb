require "spec_helper"

RSpec.describe HackerOne::Client::Swag do
  let(:api) { HackerOne::Client::Api.new("github") }

  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "bar"
  end

  let(:program) do
    VCR.use_cassette(:programs) do
      HackerOne::Client::Program.find "github"
    end
  end

  let(:swags) do
    VCR.use_cassette(:swag) do
      program.swag
    end
  end

  let(:swag) { swags[0] }

  it "returns a collection" do
    expect(swags).to be_kind_of(Array)
    expect(swags.size).to eq(8)
  end

  it "returns id" do
    expect(swag.id).to be_present
    expect(swag.id).to eq('3377')
  end

  it "returns sent?" do
    expect(swag.sent?).to be(false)
  end

  describe "address" do
    it "returns an address if present" do
      address = swag.address
      expect(address).to be_present
      expect(address).to be_kind_of(HackerOne::Client::Address)
    end

    it "returns nil if not present" do
      address = swags[1].address
      expect(address).to be_nil
    end
  end


  describe "user" do
    it "returns a user" do
      user = swag.user
      expect(user).to be_present
      expect(user).to be_kind_of(HackerOne::Client::User)
    end
  end

  describe "mark_as_sent!" do
    it "should mark the swag as sent" do
      VCR.use_cassette(:swag_sent) do
        result = swag.mark_as_sent!
        expect(result).to be_present
        expect(result.sent?).to be true
      end
    end
  end
end
