class StripeController < ApplicationController
  def handle_callback
    event_json = JSON.parse(request.body.read)
    type = event_json["type"]
    if type.include? "dispute"
      object = event_json["data"]["object"]
      # On production only care about real requests.
      if Rails.env == "production" and event_json["livemode"] == true
        process_charge(object["charge"], object["status"], type, object["amount"])
      # In development and test, well, whatever.
      else
        process_charge(object["charge"], object["status"], type, object["amount"])
      end
    elsif type.include? "invoice"
      object = event_json["data"]["object"]
      customer = Person.find_by_stripe_id(object["customer"])
      unless customer.blank?
        data = object["lines"]["data"].first
        amount = data["amount"].to_dollars
        title = data["plan"]["name"]   
        interval = data["plan"]["interval"]
        msg_desc = "You have been billed " + amount.to_s + "$ for your #{interval}ly subscription."
        PersonMailerQueue.stripe_notification(customer, title, msg_desc)
      end
    end
    # If Stripe will receive something other than 200
    # it will think as request didn't get to app and will try
    # to send it every 1 hour for 3 days.
    render nothing: true, status: 200
  end
  
  private
  # Updates charge status based on Stripe request data.
  def process_charge(charge_id, charge_status, charge_type, amount)
    charge = Charge.find_by_stripe_id(charge_id)
    unless charge.blank?
      if charge_type.include? "created"
        # Someone disputed charge.
        charge.update_attribute(:status, "disputed")
      elsif charge_status.eql? "lost"
        status = "partially refunded"
        status = "refunded" if charge.amount == amount.to_dollars 
        # Dispute is lost, cash is refunded via Stripe automatically.
        charge.update_attribute(:status, status)
      elsif charge_status.eql? "won"
        # Dispute is won, cash is returned to us.
        charge.update_attribute(:status, "paid")
      end
    end 
  end
  
end