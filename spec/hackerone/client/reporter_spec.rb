require "spec_helper"

RSpec.describe HackerOne::Client::Report do
  let(:api) { HackerOne::Client::Api.new("github") }

  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "bar"
  end

  let(:reporter) do
    VCR.use_cassette(:reporter) do
      api.reporter(200)
    end
  end

  it "returns id" do
    expect(reporter.id).to be_present
    expect(reporter.id).to be_kind_of(Integer)
  end
end
