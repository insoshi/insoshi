module ActiveScaffold::Config
  class Update < Form
    self.crud_type = :update

    # global level configuration
    # --------------------------
    # the ActionLink for this action
    def self.link
      @@link
    end
    def self.link=(val)
      @@link = val
    end
    @@link = ActiveScaffold::DataStructures::ActionLink.new('edit', :label => 'Edit', :type => :record, :security_method => :update_authorized?)

    # instance-level configuration
    # ----------------------------

    # the label= method already exists in the Form base class
    def label
      @label ? as_(@label) : as_('Update %s', @core.label.singularize)
    end

    attr_accessor :nested_links
  end
end
