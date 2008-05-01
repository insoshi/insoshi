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
      just_right.update_attributes(@attribute => "a" * @maxlength)
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
  
  class ExistInDatabase
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
    ExistInDatabase.new
  end
  
  
  # Verify that an action destroys an associated attribute.
  # Usage:
  #  @topic.should destroy_associated(:posts)

  class DestroyAssociated

    def initialize(attribute)
      @attribute = attribute
    end

    def matches?(parent)
      objects = parent.send(@attribute)
      # Objects must exist in the first place.
      raise ArgumentError, "Invalid initial association" unless found?(objects)
      parent.destroy
      not found?(objects)
    end
    
    def failure_message
      "Expected destruction of associated #{@attribute}"
    end
    
    def negative_failure_message
      "Expected destruction of associated #{@attribute}"
    end
    
    def found?(objects)
      if objects.is_a?(Array)
        # has_many
        objects.each do |object|
          object.class.find(object)
        end
      else
        # has_one
        object = objects
        object.class.find(object)
      end
      true
    rescue
      ActiveRecord::RecordNotFound
      false
    end
  end
  
  def destroy_associated(attribute)
    DestroyAssociated.new(attribute)
  end
  
end