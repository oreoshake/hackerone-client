require "spec_helper"

RSpec.describe HackerOne::Client::Report do
  let(:api) { HackerOne::Client::Api.new("github") }

  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "bar"
  end

  let(:reporters) do
    VCR.use_cassette(:reporters) do
      api.reporters
    end
  end

  let(:reporter) do
    reporters.first
  end

  it "returns a collection" do
    expect(reporters).to be_kind_of(Array)
    expect(reporters.size).to eq(2)
  end

  it "returns id" do
    expect(reporter.id).to be_present
    expect(reporter.id).to eq('3683')
  end

  it "returns disabled?" do
    expect(reporter.disabled?).to eq(false)
  end

  it "returns username" do
    expect(reporter.username).to eq("demo-hacker")
  end

  it "returns name" do
    expect(reporter.name).to eq("Demo Hacker")
  end
end
