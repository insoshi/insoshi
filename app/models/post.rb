require 'texticle/searchable'

class Post < ActiveRecord::Base
  include ActivityLogger
  has_many :activities, :as => :item, :dependent => :destroy
  attr_accessible nil

  extend Searchable(:body)
end
