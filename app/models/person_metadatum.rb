class PersonMetadatum < ActiveRecord::Base
  attr_accessible :key, :person_id, :value
  attr_accessible *attribute_names, :as => :admin

  belongs_to :person
end
