require "spec_helper"

RSpec.describe HackerOne::Client::Report do
  let(:api) { HackerOne::Client::Api.new("github") }

  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "nope"
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

  describe "#weakness" do
    it 'returns a weakness instance' do
      expect(report.weakness).to be_a(HackerOne::Client::Weakness)
    end
  end

  describe '#assign_to' do
    it 'raises if HackerOne responds with 500' do
      expect do
        VCR.use_cassette(:server_error_when_assigning_report_to_user) do
          report.assign_to 'esjee'
        end
      end.to raise_error RuntimeError
    end

    it 'can assign to users' do
      expect(
        VCR.use_cassette(:assign_report_to_user) do
          report.assign_to 'esjee'
        end
      ).to eq nil
    end

    it 'can assign to groups' do
      expect(
        VCR.use_cassette(:assign_report_to_group) do
          report.assign_to 'Admin'
        end
      ).to eq nil
    end

    it 'can assign to nobody' do
      expect(
        VCR.use_cassette(:assign_report_to_nobody) do
          report.assign_to 'nobody'
        end
      ).to eq nil
    end
  end

  describe "#activities" do
    it "returns a list of activities" do
      expect(report.activities).to all(be_an(HackerOne::Client::Activities::Activity))
    end
  end
end
