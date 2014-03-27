class FormSignupField < ActiveRecord::Base
  attr_accessible :field_type, :key, :mandatory, :order, :title
  attr_accessible *attribute_names, :as => :admin

  validates_presence_of :field_type, :key, :order, :title
end
