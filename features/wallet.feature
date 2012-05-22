Feature: Fetch my wallet of assets

So that I can identify my asset classes on an oauth client
As a user
I want to display my asset classes

  Background: A client application is registered on the server
    Given a client application

  Scenario: Successful wallet request
    Given an account holder with asset "marbles"
    And an access token
    When I request my wallet
    Then I should see "marbles" in my wallet
