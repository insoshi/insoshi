class PersonMetadatum < ActiveRecord::Base
  attr_accessible :key, :person_id, :value
  attr_accessible *attribute_names, :as => :admin

  belongs_to :person
  validate :allow_validation, :message => "This field is required"


    def allow_validation
      var = FormSignupField
        .find(:first, :conditions => {:key => self.key})
      if var.nil?
        mandatory = false
      else
        mandatory = var.mandatory
      end
      if mandatory && self.value.empty?
        # errors.add(self.key.to_sym, "#{self.key} field is required")
        errors.add(key.to_sym, "hehehe some error")
      end
      binding.pry
    end
end
