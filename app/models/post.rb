# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  blog_id    :integer
#  topic_id   :integer
#  person_id  :integer
#  title      :string(255)
#  body       :text
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'texticle/searchable'

class Post < ActiveRecord::Base
  include ActivityLogger
  has_many :activities, :as => :item, :dependent => :destroy
  attr_accessible nil

  extend Searchable(:body)
end
