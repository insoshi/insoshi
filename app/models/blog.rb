# == Schema Information
# Schema version: 25
#
# Table name: blogs
#
#  id         :integer         not null, primary key
#  person_id  :integer         
#  created_at :datetime        
#  updated_at :datetime        
#

class Blog < ActiveRecord::Base
  belongs_to :person
  has_many :posts, :order => "created_at DESC", :dependent => :destroy,
                   :class_name => "BlogPost"
end
