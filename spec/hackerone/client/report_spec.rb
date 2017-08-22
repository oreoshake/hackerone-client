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

  describe "#weakness" do
    it 'returns a weakness instance' do
      expect(report.weakness).to be_a(HackerOne::Client::Weakness)
    end
  end

  describe '#assign_to_user' do
    it 'can assign to users' do
      expect(
        VCR.use_cassette(:assign_report_to_user) do
          report.assign_to_user 'esjee'
        end
      ).to eq nil
    end

    it "fails if the API user doesn't have permission" do
      expect do
        VCR.use_cassette(:assign_report_to_user_no_permission) do
          report.assign_to_user 'esjee'
        end
      end.to raise_error RuntimeError
    end
  end

  describe '#assign_to_group' do
    it 'can assign to groups' do
      expect(
        VCR.use_cassette(:assign_report_to_group) do
          report.assign_to_group 'Admin'
        end
      ).to eq nil
    end

    it "fails if the API user doesn't have permission" do
      expect do
        VCR.use_cassette(:assign_report_to_group_no_permission) do
          report.assign_to_group 'Admin'
        end
      end.to raise_error RuntimeError
    end
  end

  describe '#unassign' do
    it 'can assign to nobody' do
      expect(
        VCR.use_cassette(:assign_report_to_nobody) do
          report.unassign
        end
      ).to eq nil
    end

    it "fails if the API user doesn't have permission" do
      expect do
        VCR.use_cassette(:assign_report_to_nobody_no_permission) do
          report.unassign
        end
      end.to raise_error RuntimeError
    end
  end

  describe '#award_bounty' do
    it 'creates a bounty' do
      result = VCR.use_cassette(:award_a_bounty) do
        report.award_bounty(
          message: 'Thanks for the great report!',
          amount: 1330,
          bonus_amount: 7
        )
      end

      expect(result).to be_a HackerOne::Client::Bounty
      expect(result.amount).to eq '1330.00'
      expect(result.bonus_amount).to eq '7.00'
      expect(result.awarded_amount).to eq '1330.00'
      expect(result.awarded_bonus_amount).to eq '7.00'
      expect(result.awarded_currency).to eq 'USD'
    end
  end

  describe '#suggest_award' do
    it 'creates a bounty' do
      result = VCR.use_cassette(:suggest_a_bounty) do
        report.suggest_bounty(
          message: 'This report is great, I think we should award a high bounty.',
          amount: 5000,
          bonus_amount: 2500
        )
      end

      expect(result).to be_a HackerOne::Client::Activities::BountySuggested
      expect(result.message).to eq 'This report is great, I think we should award a high bounty.'
      expect(result.bounty_amount).to eq '5,000'
      expect(result.bonus_amount).to eq '2,500'
    end
  end

  describe '#award_swag' do
    it 'creates a bounty' do
      result = VCR.use_cassette(:award_swag) do
        report.award_swag(
          message: 'Enjoy this cool swag!',
        )
      end

      expect(result).to be_a HackerOne::Client::Swag
      expect(result.sent).to eq false
    end
  end

  describe "#activities" do
    it "returns a list of activities" do
      expect(report.activities).to all(be_an(HackerOne::Client::Activities::Activity))
    end
  end

  describe "#structured_scope" do
    it "returns a structured_scope" do
      scope = report.structured_scope
      expect(scope).to be_an(HackerOne::Client::StructuredScope)
      expect(scope.asset_type).to eq("url")
    end
  end
end
