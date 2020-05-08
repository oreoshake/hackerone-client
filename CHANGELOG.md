## [0.19.0] - 2020-05-08

[Add ability to create a report](https://github.com/oreoshake/hackerone-client/pull/57) (@rzhade3)

## [0.18.0] - 2020-03-23

[Add ability to filter reports on states other than "new"](https://github.com/oreoshake/hackerone-client/pull/54) (@rzhade3)

## [0.17.0] - 2020-03-23

[Add support for updating the severity of an issue](https://github.com/oreoshake/hackerone-client/pull/50) (@rzhade3)

## [0.16.0] - 2020-03-23

- Whooops, no change

## [0.15.0] - 2020-03-09

- [Add 'update program policy' API support](https://github.com/oreoshake/hackerone-client/pull/47) (@rzhade3)

## [0.14.2] - 2020-03-09

- [Don't lock development dependency versions](https://github.com/oreoshake/hackerone-client/pull/45) (@oreoshake)

## [0.14.1] - 2020-02-13

- [Add support for float values in API responses](https://github.com/oreoshake/hackerone-client/pull/44) (@rzhade3)

## [0.14.0] - 2019-10-28

- [Add new swag API support](https://github.com/oreoshake/hackerone-client/pull/41) (@anglinb)

## [0.13.0] - 2018-10-19

- [Fix issue with `#to_owasp` which would raise an error if an issue classification started with `CAPEC-`](https://github.com/oreoshake/hackerone-client/pull/39) (@rzhade3)

## [0.12.0] - 2017-12-07

- [Incremental activities](https://github.com/oreoshake/hackerone-client/pull/36) - iterate over actions in a program (@esjee)

## [0.11.0] - 2017-11-03

- [Add state change hooks](https://github.com/oreoshake/hackerone-client/issues/25) (@esjee)

## [0.10.0] - 2017-11-03

Oh no! I hate versions where one number is >= 10! We should figure out what's missing for a solid 1.0 release.

- `HackerOne::Client::User.find(user_id)` returns an instance of `User` (@esjee)
- Add "original report ID" field when marking things as duplicate. This invites the reporter to the original issue.

## [0.9.1] - 2017-10-24

- Misc: loosen version restrictions on activesupport

## [0.9.0] - 2017-10-09

- API: move actions from client into report (@esjee)

This is a breaking change, but this is still not a 1.0 and shouldn't be considered stable.

## [0.8.0] - 2017-09-05

- Feature: add ability to suggest and award swag, cash, and bonuses (@esjee)

## [0.7.0] - 2017-08-28

- Feature: retrieve common responses (@esjee)

## [0.6.0] - 2017-07-24

- Feature: comments (internal or not) can be added to reports

## [0.5.2] - 2017-07-19

- Bugfix: structured scopes were not being populated correctly resulting in nil results for all attributes

## [0.5.1] - 2017-06-26

- [Structure scope](https://api.hackerone.com/docs/v1#structured-scope) data added to report object

## [0.5.0] - 2017-06-23

- `report.assign_to_user` and `report.assign_to_group` (@esjee)

## [0.4.0] - 2017-04-21

- `client.reporters` to return all reporters for a given project (@esjee)
- `HackerOne::Client::Program.find(program_name)` to return information about a given program (@esjee)
