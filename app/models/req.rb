class Req < ActiveRecord::Base
  include ActivityLogger

  has_and_belongs_to_many :categories
  belongs_to :person

  attr_accessible :name, :description, :estimated_hours, :due_date

  after_create :log_activity

  def log_activity
    add_activities(:item => self, :person => self.person)
  end
end
