module ActiveScaffold::DataStructures
  # Wrapper for error strings so that they may be exported using to_xxx
  class ErrorMessage
    def initialize(error)
      @error = error
    end

    def public_attributes
      { :error => @error }
    end

    def to_xml
      public_attributes.to_xml(:root => "errors")
    end

    def to_yaml
      public_attributes.to_yaml
    end

    def to_s
      @error
    end
  end
end