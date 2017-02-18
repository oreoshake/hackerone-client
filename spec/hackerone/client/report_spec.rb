require "spec_helper"

RSpec.describe HackerOne::Client do
  let(:api) { HackerOne::Client::Api.new("github") }
  let(:point_in_time) { DateTime.parse("2017-02-11T16:00:44-10:00") }

  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "bar"
  end

  it "classifies risk" do
    begin
      VCR.use_cassette(:report) do
        report = api.report(200)
        expect(report.risk).to eq("low")
        HackerOne::Client.low_range = 1..50
        HackerOne::Client.medium_range = 50..1000
        expect(report.risk).to eq("medium")
      end
    ensure
      HackerOne::Client.low_range = HackerOne::Client::DEFAULT_LOW_RANGE
      HackerOne::Client.medium_range = HackerOne::Client::DEFAULT_MEDIUM_RANGE
    end
  end
end
