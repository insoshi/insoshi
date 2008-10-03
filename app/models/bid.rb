class Bid < ActiveRecord::Base
  belongs_to :req
  belongs_to :person

  attr_protected :person_id, :status_id, :created_at, :updated_at
end
