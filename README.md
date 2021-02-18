# Hackerone::Client

A limited client library for interacting with HackerOne. Currently only supports a few operations:

```ruby
client = HackerOne::Client::Api.new("github")

# POST '/reports' creates a new report
client.create_report(title: "hi", summary: "hi", impact: "string", severity_rating: :high, source: "api")

# GET '/reports' returns all reports in a given state for a program, by default :new
client.reports(since: 10.days.ago, before: 1.day.ago, state: :new)

# GET '/report/{id}' returns report data for a given report
report = client.report(id)

# PUT '/reports/{id}/assignee'
report.assign_to_user("username")
report.assign_to_group("groupname")

# POST '/reports/#{id}/activities'
report.add_comment(message, internal: false) # internal is true by default

# POST '/report/{id}/state_change change the state of a report
# `state` can be one of  new, triaged, needs-more-info, resolved, not-applicable, informative, duplicate, spam
# when marking as duplicate, you can supply the original report ID
report.state_change(:duplicate, "Your issue has been marked as X", original_report_id: 12345)

# POST '/report/{id}/add_report_reference add a "reference" e.g. internal issue number
report.add_report_reference(reference)

# Triage an issue (add a reference and set state to :triaged)
report.triage(reference)

# Set the severity on a report (rating can be :none, :low, :medium, :high or :critical)
report.update_severity(rating: :high)

# POST /reports/{id}/bounty_suggestions
report.suggest_bounty(message: "I suggest $500 with a small bonus. Report is well-written.", amount: 500, bonus_amount: 50)

# POST /reports/{id}/bounties
report.award_bounty(message: "Here's your bounty!", amount: 500, bonus_amount: 50)

# POST /reports/{id}/swags
report.award_swag(message: "Here's your T-Shirt")

# GET `/{program}/reporters` returns a list of unique reporters that have reported to your program
client.reporters

program = HackerOne::Client::Program.find("insert-program-name-here")

# returns all common responses
program.common_responses

# Updates a program's policy
program.update_policy(policy: "Please submit valid vulnerabilities")

# Gets a program's balance
program.balance
```

## State change hooks

You can add hooks that will be called for every state change. This can be useful e.g. for ensuring that reports always get assigned or calling out to external services for specific state changes.

```ruby
# Initialization

HackerOne::Client::Report.add_state_change_hook ->(report, old_state, new_state) do
  # ...
end
```

## Usage

### Credential management

You'll need to generate an API token at `https://hackerone.com/<program>/api`.

* Click "Create API token"
* Name the token
* Click "Create"
* Copy down the value

**Set the `HACKERONE_TOKEN` and `HACKERONE_TOKEN_NAME` environment variables.**

### Program name

In order to retrieve all reports for a given program, you need to supply a default program:

```ruby
HackerOne::Client.program = "github"
```

### Risk classification

Configure the low/med/high/crit ranges for easier classification based on payouts:

```ruby
HackerOne::Client.low_range = 1..999
HackerOne::Client.medium_range = 1000...2500
HackerOne::Client.high_range = 2500...5000
HackerOne::Client.critical_range = 5000...100_000_000
```

### Configuration

In order to configure whether error handling is strict or lenient, set the `HACKERONE_CLIENT_LENIENT_MODE` variable.

Setting this variable will make the client try to absorb errors, like a malformed bounty or bonus amount. Not setting this variable will cause the client to raise errors.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/oreoshake/hackerone-client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
