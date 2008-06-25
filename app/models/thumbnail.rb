class Thumbnail < ActiveRecord::Base
  belongs_to :photo, :foreign_key => 'parent_id'

  has_attachment  :storage => :file_system,
                  :content_type => :image
                  
  validates_presence_of :parent_id
end
