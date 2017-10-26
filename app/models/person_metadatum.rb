# == Schema Information
#
# Table name: person_metadata
#
#  id                   :integer          not null, primary key
#  key                  :string(255)
#  value                :string(255)
#  person_id            :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  form_signup_field_id :integer
#

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
