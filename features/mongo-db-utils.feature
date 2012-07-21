Feature: MongoDbUtils
  In order to say hello
  As a CLI
  I want to be as objective as possible

  Scenario: Hello Ed
    When I run `mongo-db-utils`
    Then the output should contain "hello"

