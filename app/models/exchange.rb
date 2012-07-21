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
  belongs_to :metadata, :polymorphic => :true
  belongs_to :group

  validates_presence_of :customer, :worker, :amount, :metadata
  validates_presence_of :group_id
  validate :offer_exists
  validate :group_has_a_currency_and_includes_both_counterparties_as_members
  validate :amount_is_positive
  validate :worker_is_not_customer

  attr_accessible :amount, :group_id
  attr_accessible *attribute_names, :as => :admin
  attr_readonly :amount
  attr_readonly :customer_id, :worker_id, :group_id

  after_create :log_activity
  after_create :decrement_offer_available_count
  before_create :calculate_account_balances
  after_create :send_payment_notification_to_worker
  before_destroy :delete_calculate_account_balances

  scope :by_customer, lambda {|person_id| {:conditions => ["customer_id = ?", person_id]}}
  scope :everyone, :conditions => {}
  scope :everyone_by_group, lambda {|group_id| {:conditions => ["group_id = ?", group_id]}}
  scope :by_month, lambda {|date| {:conditions => ["DATE_TRUNC('month',created_at) = ?", date]}}

  def log_activity
    add_activities(:item => self, :person => self.worker, :group => self.group)
  end

  def self.total_on(date)
    Exchange.sum(:amount, :conditions => ["date(created_at) = ?", date])
  end

  # XXX person_id hacks for cancan's load_and_authorize_resource
  def person_id
    self.worker_id
  end

  def person_id=(worker_id)
    self.worker_id = worker_id
  end

  def self.total_on_month(date)
    Exchange.sum(:amount, :conditions => ["DATE_TRUNC('month',created_at) = ?", date])
  end

  private

  def amount_is_positive
    unless amount > 0
      errors.add(:amount, "must be greater than zero")
    end
  end

  def worker_is_not_customer
    if customer == worker
      errors.add(:worker, "cannot be not be the payer")
    end
  end

  def group_has_a_currency_and_includes_both_counterparties_as_members
    unless worker.groups.include?(self.group)
      errors.add(:group_id, "does not include recipient as a member")
    end
    unless customer.groups.include?(self.group)
      errors.add(:group_id, "does not include you as a member")
    end
    unless self.group.adhoc_currency?
      errors.add(:group_id, "does not have its own currency")
    end
  end

  def offer_exists
    if self.new_record?
      if self.metadata.class == Offer
        if self.metadata.available_count == 0
          errors.add_to_base('This offer is no longer available')
        end
      end
    end
  end

  def decrement_offer_available_count
    if self.metadata.class == Offer
      self.metadata.available_count -= 1
      self.metadata.save
    end
  end

  def calculate_account_balances
    begin
      Account.transaction do
        if group.nil?
          # this should not happen anymore
          raise "no group specified"
        else
          worker.account(group).deposit(amount)
          customer.account(group).withdraw(amount)
        end
      end
    rescue
      false
    end
  end

  def delete_calculate_account_balances
    begin
      Account.transaction do
        if group.nil?
          raise "no group specified"
        else
          worker.account(group).withdraw(amount)
          customer.account(group).deposit(amount)
          if self.metadata.class == Req
            unless self.metadata.biddable?
              self.metadata.destroy
            end
          end
        end
      end
    end
    send_suspend_payment_notification_to_worker
  end

  def send_payment_notification_to_worker
    exchange_note = Message.new()
    subject = I18n.translate('exchanges.notify.you_have_received_a_payment_of') + " " + self.amount.to_s + " " +  self.group.unit + " " + I18n.translate('for') + " " + self.metadata.name 
    exchange_note.subject =  subject.mb_chars.length > 75 ? subject.mb_chars.slice(0,75).concat("...") : subject 
    exchange_note.content = self.customer.name + " " + I18n.translate('exchanges.notify.paid_you') + " " + self.amount.to_s + " " + self.group.unit + "."
    exchange_note.sender = self.customer
    exchange_note.recipient = self.worker
    exchange_note.save!
  end

  def send_suspend_payment_notification_to_worker
    exchange_note = Message.new()
    subject = I18n.translate('exchanges.notify.payment_suspended') + self.amount.to_s + " " + self.group.unit + " - " + I18n.translate('by') + " " + self.metadata.name
    exchange_note.subject =  subject.mb_chars.length > 75 ? subject.mb_chars.slice(0,75).concat("...") : subject 
    exchange_note.content = self.customer.name + " " + I18n.translate('exchanges.notify.suspended_payment_of') + " " + self.amount.to_s + " " + self.group.unit + "."
    exchange_note.sender = self.customer
    exchange_note.recipient = self.worker
    exchange_note.save!
  end
end
