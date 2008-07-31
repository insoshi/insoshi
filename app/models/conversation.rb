class Conversation < ActiveRecord::Base
  has_many :messages, :order => :created_at
end
