# == Schema Information
# Schema version: 20090216032013
#
# Table name: forums
#
#  id           :integer(4)      not null, primary key
#  name         :string(255)     
#  description  :text            
#  topics_count :integer(4)      default(0), not null
#  created_at   :datetime        
#  updated_at   :datetime        
#

class Forum < ActiveRecord::Base
  attr_accessible :name, :description # XXX these are not used for anything. remove them?
  attr_accessible :worldwritable

  belongs_to :group
  has_many :topics, :order => "created_at DESC", :dependent => :destroy
  has_many :posts, :through => :topics

  
  validates_length_of :name, :maximum => 255, :allow_nil => true
  validates_length_of :description, :maximum => 1000, :allow_nil => true
end
