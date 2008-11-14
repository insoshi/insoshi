class Exchange < ActiveRecord::Base
  include ActivityLogger

  belongs_to :customer, :class_name => "Person", :foreign_key => "customer_id"
  belongs_to :worker, :class_name => "Person", :foreign_key => "worker_id"
  belongs_to :req

  validates_presence_of :customer, :worker, :amount, :req

  after_create :log_activity

  def log_activity
    add_activities(:item => self, :person => self.worker)
  end
end
