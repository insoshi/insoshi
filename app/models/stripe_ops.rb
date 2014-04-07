class StripeOps
  
  def self.create_customer(card, expire, cvc, name, email)
   begin
     stripe_response = Stripe::Customer.create(
       :card => {
         :number => card,
         :exp_month => expire.split("/").first,
         :exp_year => expire.split("/").last,
         :cvc => cvc
       },
       :description => name,
       :email => email
     )
   rescue => e
     stripe_response = handle_error(e)
   else
     stripe_response
   end
  end
  # Unfortunately:
  # A positive integer in the smallest currency unit (e.g 100 cents to charge $1.00).
  def self.charge(amount, stripe_id, description)
    if amount.to_cents < 50
      return "Minimum amount that can be submitted via stripe is 50 cents!"
    end
    begin
      stripe_response = Stripe::Charge.create(
        :amount => amount.to_cents,
        :currency => "usd",
        :customer => stripe_id,
        :description => description
      )
    rescue => e
      stripe_response = handle_error(e)
    else
      charge_params = {
        :stripe_id => stripe_response[:id],
        :person_id => Person.find_by_stripe_id(stripe_id).id,
        :amount => amount,
        :description => description,
        :status => 'paid'
      }
      Charge.create(charge_params)
      msg_desc = description + ": " + amount.to_s + "$"
      PersonMailerQueue.stripe_notification(Person.find_by_stripe_id(stripe_id), description, msg_desc)
      stripe_response
    end
  end

  # Data from the Stripe. For db see Charge#all_charges_for_person
  def self.all_charges_for_person(stripe_id)
    all_charges = Array.new
    charges = Stripe::Charge.all(:customer => stripe_id)
    charges.each do |charge|
      all_charges << [ 
                      charge[:id], 
                      charge[:amount].to_dollars, 
                      Person.find_by_stripe_id(charge[:customer]).email,
                      charge[:description],
                      charge[:refunded] ]
    end
    all_charges
  end
  
  def self.refund_charge(charge_id, amount)
    begin
      stripe_response = Stripe::Charge.retrieve(charge_id).refund(:amount => amount.to_cents)
    rescue => e  
      stripe_response = handle_error(e)
    else
      charge = Charge.find_by_stripe_id(charge_id)
      status = 'partially refunded'
      status = 'refunded' if charge.amount == amount 
      Charge.find_by_stripe_id(charge_id).update_attribute(:status, status)
      "Charge #{status}."
    end
  end
  
  def self.create_stripe_plan(amount, interval, name)
    begin
      stripe_response = Stripe::Plan.create(
        :amount => amount.to_cents,
        :interval => interval,
        :currency => 'usd',
        :id => name,
        :name => name
      )
    rescue => e
      stripe_response = handle_error(e)
    end
  end
  
  def self.subscribe_to_plan(customer_id, plan_name)
    begin
      stripe_ret = Stripe::Customer.retrieve(customer_id).subscriptions.create(:plan => plan_name)
    rescue => e
      stripe_response = handle_error(e)
    end
  end
  
  def self.retrieve_plan(plan_name)
    begin
      stripe_ret = Stripe::Plan.retrieve(plan_name)
    rescue => e
      stripe_response = handle_error(e)
    end
  end
  
  private
  
  def self.handle_error(e)
    case e.class
    when Stripe::CardError
      return e.json_body[:error][:message]
    when Stripe::InvalidRequestError
      return e.json_body[:error][:message]
    when Stripe::AuthenticationError
      e.json_body[:error][:message]
    else
      return e.to_s
    end 

  end
end