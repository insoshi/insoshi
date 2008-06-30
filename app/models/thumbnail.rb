# == Schema Information
# Schema version: 34
#
# Table name: thumbnails
#
#  id           :integer         not null, primary key
#  parent_id    :integer         
#  content_type :string(255)     
#  filename     :string(255)     
#  thumbnail    :string(255)     
#  size         :integer         
#  width        :integer         
#  height       :integer         
#  created_at   :datetime        
#  updated_at   :datetime        
#

class Thumbnail < ActiveRecord::Base
  belongs_to :photo, :foreign_key => 'parent_id'

  has_attachment  :storage => :file_system,
                  :content_type => :image
                  
  validates_presence_of :parent_id
end
