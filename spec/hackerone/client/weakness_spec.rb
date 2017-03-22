require "spec_helper"

RSpec.describe HackerOne::Client::Weakness do
  describe ".extract_cwe_number" do
    context "with invalid input" do
      it do
        expect { described_class.extract_cwe_number("1337")
          .to raise_error StandardError::ArgumentError }
      end
    end

    context "with valid input" do
      it { expect(described_class.extract_cwe_number("CWE-134")).to eq(134) }
    end
  end

  describe "#to_cwe" do
    it "returns the external_id" do
      expect(described_class.new(:external_id => "CWE-134").to_cwe)
        .to eq("CWE-134")
    end
  end

  describe "#to_owasp" do
    subject { described_class.new(:external_id => cwe).to_owasp }

    context "unmappable CWE" do
      let(:cwe) { "CWE-33" }

      it { is_expected.to eq("A0-Other") }
    end

    context "mappable CWE" do
      let(:cwe) { "CWE-77" }

      it { is_expected.to eq("A1-Injection") }
    end

    it "falls back to name matchin when external ID is nil" do
      classification = described_class.new(:external_id => nil, name: "Command Injection").to_owasp
      expect(classification).to eq("A1-Injection")
    end
  end
end
