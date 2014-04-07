require 'spec_helper'

describe StripeController do
  fixtures :people, :charges
  
  describe 'POST handle_callback from Stripe API webhook' do
    
    before(:each) do
      @charge = charges(:two_dollars)
      @webhooks_path = "#{Rails.root}/spec/fixtures/stripe_webhooks"
    end
    
    it 'should respond with status 200' do
      params = YAML.load_file("#{@webhooks_path}/charge_dispute_created.yml").to_json 
      @request.env["RAW_POST_DATA"] = params
      post :handle_callback
      response.status.should == 200
    end
    
    it 'should receive event and change charge status to disputed' do
      params = YAML.load_file("#{@webhooks_path}/charge_dispute_created.yml").to_json 
      @request.env["RAW_POST_DATA"] = params
      post :handle_callback
      Charge.find_by_stripe_id(@charge.stripe_id).status.should == 'disputed'
    end
    
    it 'should receive event and change charge status to partially refunded' do
      params = YAML.load_file("#{@webhooks_path}/charge_dispute_closed.yml")
      params["data"]["object"]["amount"] = (@charge.amount/2).to_cents
      @request.env["RAW_POST_DATA"] = params.to_json
      post :handle_callback
      Charge.find_by_stripe_id(@charge.stripe_id).status.should == 'partially refunded'
    end
    
    it 'should receive event and change charge status to fully refunded' do
      params = YAML.load_file("#{@webhooks_path}/charge_dispute_closed.yml")
      params["data"]["object"]["amount"] = @charge.amount.to_cents
      @request.env["RAW_POST_DATA"] = params.to_json
      post :handle_callback
      Charge.find_by_stripe_id(@charge.stripe_id).status.should == 'refunded'
    end
    
    it 'should receive event and change charge status to paid' do
      params = YAML.load_file("#{@webhooks_path}/charge_dispute_closed.yml")
      params["data"]["object"]["status"] = "won"
      @request.env["RAW_POST_DATA"] = params.to_json
      post :handle_callback
      Charge.find_by_stripe_id(@charge.stripe_id).status.should == 'paid'
    end
    
    it 'should receive invoice event and send email to user' do
      params = YAML.load_file("#{@webhooks_path}/invoice_created.yml")
      params["data"]["object"]["customer"] = "test_cus_2"
      @request.env["RAW_POST_DATA"] = params.to_json
      post :handle_callback
      sleep 1 # without it test will fail.
      PersonMailer.deliveries.should_not be_empty
    end
    
  end
end