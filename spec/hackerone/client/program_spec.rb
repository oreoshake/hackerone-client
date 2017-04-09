require "spec_helper"

RSpec.describe HackerOne::Client::Report do
  let(:api) { HackerOne::Client::Api.new("github") }

  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "bar"
  end

  let(:programs) do
    VCR.use_cassette(:programs) do
      api.programs
    end
  end

  let(:program_as_object) do
    VCR.use_cassette(:programs) do
      api.program_as_object
    end
  end

  it "returns a collection" do
    expect(programs).to be_kind_of(Array)
    expect(programs.size).to eq 1
  end

  it "returns id" do
    expect(program_as_object.id).to eq "18969"
  end

  it "returns handle" do
    expect(program_as_object.handle).to eq "github"
  end
end
