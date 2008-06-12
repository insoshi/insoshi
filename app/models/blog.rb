# == Schema Information
# Schema version: 28
#
# Table name: blogs
#
#  id         :integer(11)     not null, primary key
#  person_id  :integer(11)     
#  created_at :datetime        
#  updated_at :datetime        
#

class Blog < ActiveRecord::Base
  belongs_to :person
  has_many :posts, :order => "created_at DESC", :dependent => :destroy,
                   :class_name => "BlogPost"
end
