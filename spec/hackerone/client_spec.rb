# frozen_string_literal: true

require "spec_helper"

RSpec.describe HackerOne::Client do
  let(:api) { HackerOne::Client::Api.new("github") }
  let(:point_in_time) { DateTime.parse("2017-02-11T16:00:44-10:00") }

  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "bar"
  end

  context "configuration" do
    it "rejects invalid range values for risk classification" do
      begin
        expect { HackerOne::Client.low_range = "fred" }.to raise_error(ArgumentError)
        expect { HackerOne::Client.low_range = nil }.to raise_error(ArgumentError)
        expect { HackerOne::Client.low_range = 1..10000 }.to_not raise_error
      ensure
        HackerOne::Client.low_range = HackerOne::Client::DEFAULT_LOW_RANGE
      end
    end

    it "requires credential env vars" do
      begin
        ENV["HACKERONE_TOKEN_NAME"] = nil
        ENV["HACKERONE_TOKEN"] = nil
        expect {
          api.report(200)
        }.to raise_error(HackerOne::Client::NotConfiguredError)
      ensure
        ENV["HACKERONE_TOKEN_NAME"] = "foo"
        ENV["HACKERONE_TOKEN"] = "bar"
      end
    end
  end

  context "#report" do
    it "fetches and populates a report" do
      VCR.use_cassette(:report) do
        expect(api.report(200)).to_not be_nil
      end
    end

    it "raises an exception if a report is not found" do
      VCR.use_cassette(:missing_report) do
        expect { api.report(404) }.to raise_error(ArgumentError)
      end
    end

    it "raises an error if hackerone 500s" do
      VCR.use_cassette(:server_error) do
        expect { api.report(500) }.to raise_error(RuntimeError)
      end
    end
  end

  context "#reports" do
    it "raises an error if no program is supplied" do
      expect { HackerOne::Client::Api.new.reports }.to raise_error(ArgumentError)
    end

    it "returns new reports for a default program as default" do
      begin
        HackerOne::Client.program = "github"
        VCR.use_cassette(:report_list) do
          expect(HackerOne::Client::Api.new.reports(since: point_in_time)).to_not be_empty
        end
      ensure
        HackerOne::Client.program = nil
      end
    end

    it "returns new reports for a given program as default" do
      VCR.use_cassette(:report_list) do
        expect(api.reports(since: point_in_time)).to_not be_empty
      end
    end

    it "returns an empty array if no reports are found" do
      VCR.use_cassette(:empty_report_list) do
        expect(api.reports(since: point_in_time)).to be_empty
      end
    end

    it "returns triaged reports for a default program" do
      begin
        HackerOne::Client.program = "github"
        VCR.use_cassette(:report_list_triaged) do
          expect(HackerOne::Client::Api.new.reports(since: point_in_time, state: "triaged")).to_not be_empty
        end
      ensure
        HackerOne::Client.program = nil
      end
    end

    it "returns triaged reports for a given program" do
      VCR.use_cassette(:report_list_triaged) do
        expect(api.reports(since: point_in_time, state: "triaged")).to_not be_empty
      end
    end
  end
end
