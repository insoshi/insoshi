Feature: List transactions

So that I can present account activity to an account holder
As an OpenTransact consumer
I want to access transactions on behalf of an account holder

  Background: A client application is registered on the server
    Given a client application

    
  Scenario: Successful transactions request
    Given an account holder with asset "marbles"
    And an access token with scope "http://localhost:3000/scopes/list_payments.json?asset=marbles"
    When I request transactions for "marbles"
    Then I should see her transactions for "marbles"

  Scenario: Unauthorized all transactions request because account holder is not an admin
    Given an account holder with asset "marbles"
    And an access token with scope "http://localhost:3000/scopes/list_all_payments.json?asset=marbles"
    When I request transactions for "marbles"
    Then I should see her transactions for "marbles"

  Scenario: Successful all transactions request for system admin
    Given an account holder with asset "marbles"
    And the account holder is a system admin
    And an access token with scope "http://localhost:3000/scopes/list_all_payments.json?asset=marbles"
    When I request transactions for "marbles"
    Then I should see all transactions for "marbles"

  Scenario: Successful all transactions request for group admin
    Given an account holder with asset "marbles"
    And the account holder is an admin for the group with asset "marbles"
    And an access token with scope "http://localhost:3000/scopes/list_all_payments.json?asset=marbles"
    When I request transactions for "marbles"
    Then I should see all transactions for "marbles"

  Scenario: Unknown asset specified
    Given an account holder with asset "marbles"
    And an access token with scope "http://localhost:3000/scopes/list_payments.json?asset=marbles"
    When I request transactions for "jacks"
    Then I should receive error message "Unknown asset"

  Scenario: No asset specified
    Given an account holder with asset "marbles"
    And an access token with scope "http://localhost:3000/scopes/list_payments.json?asset=marbles"
    When I request transactions for ""
    Then I should receive error message "No asset specified"

  Scenario: Asset specified does not match token
    Given an account holder with asset "marbles"
    And another asset called "jacks"
    And an access token with scope "http://localhost:3000/scopes/list_payments.json?asset=marbles"
    When I request transactions for "jacks"
    Then I should receive error message "Bad scope"

  Scenario: Successful transactions request with no asset specified in scope
    Given an account holder with asset "marbles"
    And an access token with scope "http://localhost:3000/scopes/list_payments.json"
    When I request transactions for "marbles"
    Then I should see her transactions for "marbles"

  Scenario: Successful transactions request with multiple scopes
    Given an account holder with asset "marbles"
    And an access token with scope "http://localhost:3000/scopes/wallet.json http://localhost:3000/scopes/list_payments.json"
    When I request transactions for "marbles"
    Then I should see her transactions for "marbles"
