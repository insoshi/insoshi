class Req < ActiveRecord::Base
  include ActivityLogger

  has_and_belongs_to_many :categories
  belongs_to :person
  has_many :bids

  attr_protected :person_id

  after_create :log_activity

  def log_activity
    add_activities(:item => self, :person => self.person)
  end
end
