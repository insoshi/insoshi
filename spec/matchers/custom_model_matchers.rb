module CustomModelMatchers
  
  # Verify that a model instance has a maximum length on the given attribute.
  class MaximumLength
    def initialize(attribute, maxlength)
      @attribute = attribute
      @maxlength = maxlength
    end
    
    def matches?(model)
      @model = model
      just_right = model
      too_long   = model.clone
      just_right.update_attributes(@attribute => "a" * 70)
      too_long.update_attributes(@attribute => "a" * (@maxlength + 1))
      just_right.valid? and not too_long.valid?
    end
    
    def failure_message
      "#{@model.to_s} #{@attribute} should have maximum length #{@maxlength}"
    end
  end
  
  def have_maximum(attribute, maxlength)
    MaximumLength.new(attribute, maxlength)
  end
  
  class ExistInDb
    def initialize
    end
    
    def matches?(model)
      model.class.find(model)
      true
    rescue
      ActiveRecord::RecordNotFound
      false
    end

    def failure_message
      "Object should exist in the database but doesn't"
    end
    
    def negative_failure_message
      "Object shouldn't exist in the database but does"      
    end
  end
  
  def exist_in_database
    ExistInDb.new
  end
  
end