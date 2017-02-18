require "spec_helper"

RSpec.describe HackerOne::Client::Report do
  let(:api) { HackerOne::Client::Api.new("github") }

  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "bar"
  end

  let(:report) do
    VCR.use_cassette(:report) do
      api.report(200)
    end
  end

  it "classifies risk" do
    begin
      expect(report.risk).to eq("low")
      HackerOne::Client.low_range = 1..50
      HackerOne::Client.medium_range = 50..1000
      expect(report.risk).to eq("medium")
    ensure
      HackerOne::Client.low_range = HackerOne::Client::DEFAULT_LOW_RANGE
      HackerOne::Client.medium_range = HackerOne::Client::DEFAULT_MEDIUM_RANGE
    end
  end

  it "calculates payments" do
    expect(report.payment_total).to eq(750)
  end

  it "returns reporter info" do
    expect(report.reporter).to be_kind_of(Hash)
  end

  it "maps results to the owasp top 10" do
    expect(report.classification_label).to eq("A6-DataExposure")
  end
end
