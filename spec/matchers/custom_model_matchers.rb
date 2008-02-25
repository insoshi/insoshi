module CustomModelMatchers
  class MaximumLength
    def initialize(attribute, maxlength)
      @attribute = attribute
      @maxlength = maxlength
    end
    
    def matches?(target)
      @target = target
      !@target.new(@attribute => "a" * (@maxlength + 1)).valid?
    end
    
    def failure_message
      "#{@target} #{@attribute} should have maximum length #{@maxlength}"
    end
  end
  
  def have_maximum(attribute, maxlength)
    MaximumLength.new(attribute, maxlength)
  end
end