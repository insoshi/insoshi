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
end