# == Schema Information
# Schema version: 20090216032013
#
# Table name: states
#
#  id           :integer(4)      not null, primary key
#  name         :string(25)      default(""), not null
#  abbreviation :string(2)       default(""), not null
#  created_at   :datetime        
#  updated_at   :datetime        
#

class State < ActiveRecord::Base
  has_many :addresses
end
