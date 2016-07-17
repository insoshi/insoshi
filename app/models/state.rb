# == Schema Information
#
# Table name: states
#
#  id           :integer          not null, primary key
#  name         :string(25)       not null
#  abbreviation :string(2)        not null
#  created_at   :datetime
#  updated_at   :datetime
#

class State < ActiveRecord::Base
  has_many :addresses
end
