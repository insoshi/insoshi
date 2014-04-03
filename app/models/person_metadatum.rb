class PersonMetadatum < ActiveRecord::Base
  attr_accessible :id, :key, :person_id, :value, :person_metadatum
  attr_accessible :person_attributes, :allow_destroy => true
  attr_accessible *attribute_names, :as => :admin

  belongs_to :person, :inverse_of => :person_metadata
  validate :allow_validation

  belongs_to :form_signup_field

  def allow_validation
    var = FormSignupField
      .find(:first, :conditions => {:key => self.key})
    if var.nil?
      mandatory = false
    else
      mandatory = var.mandatory
    end
    if mandatory && self.value.empty?
      errors.add(key.to_sym, "is required")
    end
  end
end
