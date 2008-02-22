class Photo < ActiveRecord::Base
  belongs_to :person
  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :max_size => 5.megabytes,
                 :min_size => 1,
                 :resize_to => '350x350>',
                 :thumbnails => { :thumbnail => '110x110>',
                                  :icon      => '40x40>' },
                 :processor => 'ImageScience'
  validates_as_attachment
end
