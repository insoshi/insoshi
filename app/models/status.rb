# == Schema Information
# Schema version: 20090216032013
#
# Table name: statuses
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class Status < ActiveRecord::Base
end
