# == Schema Information
# Schema version: 20090216032013
#
# Table name: exchanges
#
#  id          :integer(4)      not null, primary key
#  customer_id :integer(4)      
#  worker_id   :integer(4)      
#  req_id      :integer(4)      
#  amount      :decimal(8, 2)   default(0.0)
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Exchange < ActiveRecord::Base
  include ActivityLogger

  belongs_to :customer, :class_name => "Person", :foreign_key => "customer_id"
  belongs_to :worker, :class_name => "Person", :foreign_key => "worker_id"
  belongs_to :req
  belongs_to :group

  validates_presence_of :customer, :worker, :amount, :req

  attr_accessible :amount, :group_id

  after_create :log_activity
  before_save :calculate_account_balances
  after_save :send_payment_notification_to_worker
  before_destroy :send_suspend_payment_notification_to_worker

  def log_activity
    add_activities(:item => self, :person => self.worker)
  end

  private

  def validate
    unless amount > 0
      errors.add(:amount, "must be greater than zero")
    end

    unless self.group.nil?
      unless worker.groups.include?(self.group)
        errors.add(:group_id, "does not include recipient as a member")
      end
      unless customer.groups.include?(self.group)
        errors.add(:group_id, "does not include you as a member")
      end
    end
  end

  def calculate_account_balances
    begin
      Account.transaction do
        if group.nil?
          worker.account.deposit(amount)
          customer.account.withdraw(amount)
        else
          worker.accounts.find(:first, :conditions => ["group_id = ?",group.id]).deposit(amount)
          customer.accounts.find(:first, :conditions => ["group_id = ?",group.id]).withdraw(amount)
        end
      end
    rescue
      self.req.destroy
    end
  end

  def send_payment_notification_to_worker
    exchange_note = Message.new()
    subject = "PAYMENT: " + self.amount.to_s + " hours - from " + self.req.name 
    exchange_note.subject =  subject.length > 75 ? subject.slice(0,75).concat("...") : subject 
    exchange_note.content = "This is an automatically generated system notice: " + self.customer.name + " paid you " + self.amount.to_s + " hours."
    exchange_note.sender = self.customer
    exchange_note.recipient = self.worker
    exchange_note.save!
  end

  def send_suspend_payment_notification_to_worker
    exchange_note = Message.new()
    subject = "PAYMENT SUSPENDED: " + self.amount.to_s + " hours - by " + self.req.name
    exchange_note.subject =  subject.length > 75 ? subject.slice(0,75).concat("...") : subject 
    exchange_note.content = "This is an automatically generated system notice: " + self.customer.name + " suspended payment of " + self.amount.to_s + " hours."
    exchange_note.sender = self.customer
    exchange_note.recipient = self.worker
    exchange_note.save!
  end
end
