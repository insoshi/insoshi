require "spec_helper"
require "authlogic/test_case"

# Only way to access Application Controller methods in test env.
class ApplicationController < ActionController::Base
  class CreditCardReqTester < StandardError; end
  class CheckCreditCardTester < StandardError; end
  rescue_from CreditCardReqTester, :with => :credit_card_required
  rescue_from CheckCreditCardTester, :with => :check_credit_card
end

describe ApplicationController do
  # Required for logging in
  include Authlogic::TestCase
  
  fixtures :people, :fee_plans, :stripe_fees

  # Logging in.
  before(:each) do
    activate_authlogic
    @person = people(:aaron)
    PersonSession.create({:email => @person.email, :password => "benrocks"})
    controller.stub(:current_user).and_return @person
  end
  
  # Anonymous controller for invoking actions from ApplicationController
  controller do
    def credit_card_req_test
      raise ApplicationController::CreditCardReqTester
    end
    
    def check_credit_card_test
      raise ApplicationController::CheckCreditCardTester
    end  
  end
  
  it "should redirect to credit card path if person needs to submit their credit card credentials" do
    routes.draw { get "credit_card_req_test" => "anonymous#credit_card_req_test" }
    get :credit_card_req_test
    response.redirect_url.should include("/credit_card")
  end
  
  it "should redirect to credit card path if admin allowed person to not put credit card " + 
      "credentials, but person wants to make exchange" do
    routes.draw { get "check_credit_card_test" => "anonymous#check_credit_card_test" }
    Person.find_by_name('Aaron').update_attribute(:requires_credit_card, false)
    get :check_credit_card_test
    response.redirect_url.should include("/credit_card")
  end
  
end
