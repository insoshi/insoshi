class Blog < ActiveRecord::Base
  belongs_to :person
  has_many :posts, :order => "created_at DESC", :dependent => :destroy,
                   :class_name => "BlogPost"
end
