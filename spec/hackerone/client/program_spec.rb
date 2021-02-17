# frozen_string_literal: true

require "spec_helper"

RSpec.describe HackerOne::Client::Program do
  before(:all) do
    ENV["HACKERONE_TOKEN_NAME"] = "foo"
    ENV["HACKERONE_TOKEN"] = "bar"
  end

  let(:program) do
    VCR.use_cassette(:programs) do
      described_class.find "github"
    end
  end

  describe "find" do
    it "returns a team as object when provided the handle" do
      expect(program.id).to eq("18969")
      expect(program.handle).to eq("github")
    end
  end

  describe "common responses" do
    it "returns the common responses of the program" do
      expect(
        VCR.use_cassette(:common_responses) do
          program.common_responses
        end
      ).to be_present
    end
  end

  describe "policy" do
    it "updates the policy of the program" do
      expect(
        VCR.use_cassette(:update_policy) do
          program.update_policy(policy: "Hello World, updating policy")
        end
      ).to be_present
    end
  end

  describe "swag" do
    it "returns the pending swag awards for the program" do
      expect(
        VCR.use_cassette(:swag) do
          program.swag
        end
      ).to be_present
    end
  end

  describe ".incremental_activities" do
    it "can traverse through the activities of a program" do
      incremental_activities = program.incremental_activities(updated_at_after: DateTime.new(2017, 12, 4, 15, 38), page_size: 3)

      activities = []
      VCR.use_cassette(:traverse_through_3_activities) do
        incremental_activities.traverse do |activity|
          activities << activity
        end
      end

      expect(activities.size).to eq 3
      group_assigned_to_bug, comment_added, bounty_awarded = activities
      expect(group_assigned_to_bug)
        .to be_a HackerOne::Client::Activities::GroupAssignedToBug
      expect(group_assigned_to_bug.group).to be_present
      expect(group_assigned_to_bug.group.name).to eq "Standard"
      expect(comment_added)
        .to be_a HackerOne::Client::Activities::CommentAdded
      expect(comment_added.message).to eq "this is a comment"
      expect(bounty_awarded)
        .to be_a HackerOne::Client::Activities::BountyAwarded
      expect(bounty_awarded.message).to eq "Here's a bounty!"
    end

    it "can traverse through all activities of a program" do
      incremental_activities = program.incremental_activities

      activities = []
      VCR.use_cassette(:traverse_through_all_activities) do
        incremental_activities.traverse do |activity|
          activities << activity
        end
      end

      expect(activities.size).to eq 27

      # Assert no activity appears twice
      name_and_updated_at = activities.map do |activity|
        "#{activity.class} #{activity.updated_at}"
      end
      expect(name_and_updated_at.size).to eq name_and_updated_at.uniq.size
    end
  end

  describe "balance" do
    it "gets the balance of a program" do
      expect(
        VCR.use_cassette(:get_balance) do
          program.balance
        end
      ).to eq("118386.40")
    end
  end
end
