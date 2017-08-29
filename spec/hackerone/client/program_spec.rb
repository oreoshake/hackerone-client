require "spec_helper"

RSpec.describe HackerOne::Client::Program do
  let(:api) { HackerOne::Client::Api.new("github") }

  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "bar"
  end

  let(:program) do
    VCR.use_cassette(:programs) do
      described_class.find "github"
    end
  end

  describe 'find' do
    it "returns a team as object when provided the handle" do
      expect(program.id).to eq("18969")
      expect(program.handle).to eq("github")
    end
  end

  describe 'common responses' do
    it "returns the common responses of the program" do
      expect(
        VCR.use_cassette(:common_responses) do
          program.common_responses
        end
      ).to be_present
    end
  end
end
