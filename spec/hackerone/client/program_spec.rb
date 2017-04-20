require "spec_helper"

RSpec.describe HackerOne::Client::Program do
  let(:api) { HackerOne::Client::Api.new("github") }

  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "bar"
  end

  describe 'find' do
    let(:found_program) do
      VCR.use_cassette(:programs) do
        described_class.find "github"
      end
    end

    it "returns a team as object when provided the handle" do
      expect(found_program.id).to eq("18969")
      expect(found_program.handle).to eq("github")
    end
  end
end
