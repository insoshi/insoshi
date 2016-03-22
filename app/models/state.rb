# == Schema Information
#
# Table name: states
#
#  id           :integer          not null, primary key
#  name         :string(25)       not null
#  abbreviation :string(2)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class State < ActiveRecord::Base
  has_many :addresses
end
