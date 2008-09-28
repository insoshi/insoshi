class Req < ActiveRecord::Base
  has_and_belongs_to_many :categories
  belongs_to :person

  attr_accessible :name, :description, :estimated_hours, :due_date
end
