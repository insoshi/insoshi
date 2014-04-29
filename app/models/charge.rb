class Charge < ActiveRecord::Base
  attr_accessible :stripe_id, :description, :amount, :status, :person_id
  
  validates_inclusion_of :status, :in => ['pending', 'paid', 'refunded', 'partially refunded', 'disputed']
  validates_presence_of [:stripe_id, :description, :amount, :status, :person_id]
  
  belongs_to :person
  
  scope :by_time, lambda {|time_start, time_end| {:conditions => ["created_at BETWEEN ? AND ?", time_start, time_end+1.day] } }
  
  # Data from db. For Stripe see StripeOps#all_charges_for_person
  def self.all_charges_for(person_id, interval)
    today = Date.today
    time_start = today.method("beginning_of_#{interval}").call
    time_end = today.method("end_of_#{interval}").call
    Charge.where(:person_id => person_id).by_time(time_start, time_end)
          .map{ |c| {:amount => c.amount, 
                     :status => c.status, 
                     :desc => c.description, 
                     :created_at => c.created_at.strftime("%B %d, %Y %H:%M")} }
  end
  
  def self.charges_sum_for(person_id, interval)
    charges = Charge.all_charges_for(person_id, interval)
    charges.map{ |c| c[:amount] }.sum
  end
  
  def dispute_link
    "https://manage.stripe.com/" + Rails.configuration.stripe[:mode] + "/payments/" + self.stripe_id
  end
end