module ActiveScaffold::Config
  class Show < Base
    self.crud_type = :read

    def initialize(core_config)
      @core = core_config
      # start with the ActionLink defined globally
      @link = self.class.link.clone
    end

    # global level configuration
    # --------------------------
    cattr_accessor :link
    @@link = ActiveScaffold::DataStructures::ActionLink.new('show', :label => :show, :type => :member, :security_method => :show_authorized?)
    # instance-level configuration
    # ----------------------------

    # the ActionLink for this action
    attr_accessor :link
    # the label for this action. used for the header.
    attr_writer :label
    def label
      @label ? as_(@label) : as_(:show_model, :model => @core.label(:count => 1))
    end

    # provides access to the list of columns specifically meant for this action to use
    def columns
      self.columns = @core.columns._inheritable unless @columns # lazy evaluation
      @columns
    end
    
    public :columns=
  end
end
