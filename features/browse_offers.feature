Feature: Browse Offers

So that I can see what goods I can purchase 
As a customer
I want to see offers

  Scenario: Add an offer to a category
    Given a category named Vegetables:Beans
    When I create an offer Green Beans in the Vegetables:Beans category
    Then Green Beans should be in the Vegetables category

