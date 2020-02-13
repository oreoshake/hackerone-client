require 'spec_helper'
require 'active_support/core_ext/hash'

RSpec.describe HackerOne::Client::Activities do
  describe HackerOne::Client::Activities::BountyAwarded do
    let(:example) do
      {
        'id' => '1337',
        'type' => 'activity-bounty-awarded',
        'attributes' => {
          'message' => 'Bounty Awarded!',
          'created_at' => '2016-02-02T04:05:06.000Z',
          'updated_at' => '2016-02-02T04:05:06.000Z',
          'internal' => false,
          'bounty_amount' => '500.00',
          'bonus_amount' => '50.00'
        },
        'relationships' => {
          'actor' => {
            'data' => {
              'id' => '1337',
              'type' => 'program',
              'attributes' => {
                'handle' => 'security',
                'created_at' => '2016-02-02T04:05:06.000Z',
                'updated_at' => '2016-02-02T04:05:06.000Z'
              }
            }
          }
        }
      }.with_indifferent_access
    end

    before(:each) do
      ENV.delete("HACKERONE_CLIENT_LENIENT_MODE")
    end

    it 'creates the activity type with attributes' do
      activity = HackerOne::Client::Activities.build example

      expect(activity.class).to eq described_class
      expect(activity.bounty_amount).to eq 500.00
      expect(activity.bonus_amount).to eq 50.00
    end

    it 'does not fail when bounty or bonus amount is not given' do
      example = {
        'type' => 'activity-bounty-awarded',
        'attributes' => {}
      }.with_indifferent_access

      activity = HackerOne::Client::Activities.build example

      expect(activity.bounty_amount).to eq 0
      expect(activity.bonus_amount).to eq 0
    end

    it 'throws an error when bounty amount or bonus amount is malformed' do
      example = {
        'type' => 'activity-bounty-awarded',
        'attributes' => {
          'bounty_amount' => 'steve',
          'bonus_amount' => 'harvey'
        }
      }.with_indifferent_access

      activity = HackerOne::Client::Activities.build example

      expect{ activity.bounty_amount }.to raise_error "Improperly formatted bounty amount"
      expect{ activity.bonus_amount }.to raise_error "Improperly formatted bonus amount"
    end

    it 'returns 0 when bounty amount or bonus amount are malformed with lenient mode' do
      ENV['HACKERONE_CLIENT_LENIENT_MODE'] = 'true'
      example = {
        'type' => 'activity-bounty-awarded',
        'attributes' => {
          'bounty_amount' => 'steve',
          'bonus_amount' => 'harvey'
        }
      }.with_indifferent_access

      activity = HackerOne::Client::Activities.build example

      expect(activity.bounty_amount).to eq 0
      expect(activity.bonus_amount).to eq 0
    end
  end

  describe HackerOne::Client::Activities::SwagAwarded do
    let(:example) do
      {
        'id' => '1337',
        'type' => 'activity-swag-awarded',
        'attributes' => {
          'message' => 'Swag Awarded!',
          'created_at' => '2016-02-02T04:05:06.000Z',
          'updated_at' => '2016-02-02T04:05:06.000Z',
          'internal' => false
        },
        'relationships' => {
          'actor' => {
            'data' => {
              'id' => '1337',
              'type' => 'user',
              'attributes' => {
                'username' => 'api-example',
                'name' => 'API Example',
                'disabled' => false,
                'created_at' => '2016-02-02T04:05:06.000Z',
                'profile_picture' => {
                  '62x62' => '/assets/avatars/default.png',
                  '82x82' => '/assets/avatars/default.png',
                  '110x110' => '/assets/avatars/default.png',
                  '260x260' => '/assets/avatars/default.png'
                }
              }
            }
          },
          'swag' => {
            'data' => {
              'id' => '1337',
              'type' => 'swag',
              'attributes' => {
                'sent' => false,
                'created_at' => '2016-02-02T04:05:06.000Z'
              },
              'relationships' => {
                'address' => {
                  'data' => {
                    'id' => '1337',
                    'type' => 'address',
                    'attributes' => {
                      'name' => 'Jane Doe',
                      'street' => '535 Mission Street',
                      'city' => 'San Francisco',
                      'postal_code' => '94105',
                      'state' => 'CA',
                      'country' => 'United States of America',
                      'created_at' => '2016-02-02T04:05:06.000Z',
                      'tshirt_size' => 'Large',
                      'phone_number' => '+1-510-000-0000'
                    }
                  }
                }
              }
            }
          }
        }
      }.with_indifferent_access
    end

    it 'creates the activity type with attributes' do
      activity = HackerOne::Client::Activities.build example

      expect(activity.class).to eq described_class
      expect(activity.swag).to_not be_nil
    end
  end

  describe HackerOne::Client::Activities::CommentAdded do
    let(:example) do
      {
        "id" => "1337",
        "type" => "activity-comment",
        "attributes" => {
          "message" => "A fix has been deployed. Can you retest, please?",
          "created_at" => "2016-02-02T04:05:06.000Z",
          "updated_at" => "2016-02-02T04:05:06.000Z",
          "internal" => false
        },
        "relationships" => {
          "actor" => {
            "data" => {
              "id" => "1337",
              "type" => "user",
              "attributes" => {
                "username" => "api-example",
                "name" => "API Example",
                "disabled" => false,
                "created_at" => "2016-02-02T04:05:06.000Z",
                "profile_picture" => {
                  "62x62" => "/assets/avatars/default.png",
                  "82x82" => "/assets/avatars/default.png",
                  "110x110" => "/assets/avatars/default.png",
                  "260x260" => "/assets/avatars/default.png"
                }
              }
            }
          }
        }
      }.with_indifferent_access
    end

    it 'creates the activity type with attributes' do
      activity = HackerOne::Client::Activities.build example

      expect(activity.class).to eq described_class
      expect(activity.message).to_not be_nil
      expect(activity.internal).to_not be_nil
    end
  end

  describe HackerOne::Client::Activities::UserAssignedToBug do
    let(:example) do
      {
        "id" => "1337",
        "type" => "activity-user-assigned-to-bug",
        "attributes" => {
          "message" => "User Assigned To Bug!",
          "created_at" => "2016-02-02T04:05:06.000Z",
          "updated_at" => "2016-02-02T04:05:06.000Z",
          "internal" => true
        },
        "relationships" => {
          "actor" => {
            "data" => {
              "id" => "1337",
              "type" => "user",
              "attributes" => {
                "username" => "api-example",
                "name" => "API Example",
                "disabled" => false,
                "created_at" => "2016-02-02T04:05:06.000Z",
                "profile_picture" => {
                  "62x62" => "/assets/avatars/default.png",
                  "82x82" => "/assets/avatars/default.png",
                  "110x110" => "/assets/avatars/default.png",
                  "260x260" => "/assets/avatars/default.png"
                }
              }
            }
          },
          "assigned_user" => {
            "data" => {
              "id" => "1336",
              "type" => "user",
              "attributes" => {
                "username" => "other_user",
                "name" => "Other User",
                "disabled" => false,
                "created_at" => "2016-02-02T04:05:06.000Z",
                "profile_picture" => {
                  "62x62" => "/assets/avatars/default.png",
                  "82x82" => "/assets/avatars/default.png",
                  "110x110" => "/assets/avatars/default.png",
                  "260x260" => "/assets/avatars/default.png"
                }
              }
            }
          }
        }
      }.with_indifferent_access
    end

    it 'creates the activity type with attributes' do
      activity = HackerOne::Client::Activities.build example

      expect(activity.class).to eq described_class
      expect(activity.assigned_user).to_not be_nil
    end
  end

  describe HackerOne::Client::Activities::BugTriaged do
    let(:example) do
      {
        "id" => "1337",
        "type" => "activity-bug-triaged",
        "attributes" => {
          "message" => "Bug Triaged!",
          "created_at" => "2016-02-02T04:05:06.000Z",
          "updated_at" => "2016-02-02T04:05:06.000Z",
          "internal" => false
        },
        "relationships" => {
          "actor" => {
            "data" => {
              "id" => "1337",
              "type" => "user",
              "attributes" => {
                "username" => "api-example",
                "name" => "API Example",
                "disabled" => false,
                "created_at" => "2016-02-02T04:05:06.000Z",
                "profile_picture" => {
                  "62x62" => "/assets/avatars/default.png",
                  "82x82" => "/assets/avatars/default.png",
                  "110x110" => "/assets/avatars/default.png",
                  "260x260" => "/assets/avatars/default.png"
                }
              }
            }
          }
        }
      }.with_indifferent_access
    end

    it 'creates the activity type with attributes' do
      activity = HackerOne::Client::Activities.build example

      expect(activity.class).to eq described_class
    end
  end

  describe HackerOne::Client::Activities::ReferenceIdAdded do
    let(:example) do
      {
        "id" => "1337",
        "type" => "activity-reference-id-added",
        "attributes" => {
          "message" => "Reference Id Added!",
          "created_at" => "2016-02-02T04:05:06.000Z",
          "updated_at" => "2016-02-02T04:05:06.000Z",
          "internal" => true,
          "reference" => "reference",
          "reference_url" => "https://example.com/reference"
        },
        "relationships" => {
          "actor" => {
            "data" => {
              "id" => "1337",
              "type" => "user",
              "attributes" => {
                "username" => "api-example",
                "name" => "API Example",
                "disabled" => false,
                "created_at" => "2016-02-02T04:05:06.000Z",
                "profile_picture" => {
                  "62x62" => "/assets/avatars/default.png",
                  "82x82" => "/assets/avatars/default.png",
                  "110x110" => "/assets/avatars/default.png",
                  "260x260" => "/assets/avatars/default.png"
                }
              }
            }
          }
        }
      }.with_indifferent_access
    end

    it 'creates the activity type with attributes' do
      activity = HackerOne::Client::Activities.build example

      expect(activity.class).to eq described_class
      expect(activity.reference).to eq "reference"
      expect(activity.reference_url).to eq "https://example.com/reference"
    end
  end
end
