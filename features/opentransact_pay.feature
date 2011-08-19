Feature: Make a payment

So that I can withdraw money from an account holder
As an OpenTransact consumer
I want to make a payment on behalf of an account holder

  Background: A client application is registered on the server
    Given a client application
    And using opentransact gem

  Scenario: Successful payment
    Given an account holder with asset "marbles"
    And an account holder with email "service@bank.com" and asset "marbles"
    And an access token with scope "http://localhost:3000/scopes/single_payment.json?amount=10&asset=marbles"
    When I pay "10" "marbles" to "service@bank.com"
    Then I should see a new transaction with amount "10"

  Scenario: Unknown asset specified
    Given an account holder with asset "marbles"
    And an account holder with email "service@bank.com" and asset "marbles"
    And an access token with scope "http://localhost:3000/scopes/single_payment.json?amount=10&asset=marbles"
    When I pay "10" "jacks" to "service@bank.com"
    Then I should receive error message "Unknown asset"

  Scenario: No asset specified
    Given an account holder with asset "marbles"
    And an account holder with email "service@bank.com" and asset "marbles"
    And an access token with scope "http://localhost:3000/scopes/single_payment.json?amount=10&asset=marbles"
    When I pay "10" "" to "service@bank.com"
    Then I should receive error message "No asset specified"

  Scenario: Asset specified does not match token
    Given an account holder with asset "marbles"
    And an account holder with email "service@bank.com" and asset "marbles"
    And another asset called "jacks"
    And an access token with scope "http://localhost:3000/scopes/single_payment.json?amount=10&asset=marbles"
    When I pay "10" "jacks" to "service@bank.com"
    Then I should receive error message "Bad scope"

  Scenario: Scope exists but is invalidated
    Given an account holder with asset "marbles"
    And an account holder with email "service@bank.com" and asset "marbles"
    And an access token with scope "http://localhost:3000/scopes/single_payment.json?amount=10&asset=marbles"
    And the scope "http://localhost:3000/scopes/single_payment.json?amount=10&asset=marbles" is invalidated
    When I pay "10" "marbles" to "service@bank.com"
    Then I should receive error message "Bad scope"
