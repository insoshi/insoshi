Feature: Register a client dynamically

So that I can communicate with a compatible provider
As an OAuth consumer
I want to automate registering a new client application

Scenario: Successful normal client registration
	Given a client registration endpoint
	When I make a client registration request
	Then I should see a new client id

Scenario: Successful client registration asking provider to choose redirect uri
	Given a client registration endpoint
	When I make a noredirect client registration request
        Then I should see a new client id
        And I should see a new redirect url

Scenario: Failure normal client registration - missing request param
	Given a client registration endpoint
	When I exclude name from a client registration request
        Then I should see an error

Scenario: Failure normal client registration - blank request param
	Given a client registration endpoint
	When I send empty name in a client registration request
	Then I should see an error
