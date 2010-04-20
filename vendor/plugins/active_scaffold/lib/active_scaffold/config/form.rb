module ActiveScaffold::Config
  class Form < Base
    def initialize(core_config)
      @core = core_config

      # start with the ActionLink defined globally
      @link = self.class.link.clone

      # no global setting here because multipart should only be set for specific forms
      @multipart = false
    end

    # global level configuration
    # --------------------------

    # instance-level configuration
    # ----------------------------

    # the ActionLink for this action
    attr_accessor :link

    # the label for this Form action. used for the header.
    attr_writer :label
    def label
      as_(@label)
    end

    # provides access to the list of columns specifically meant for the Form to use
    def columns
      unless @columns # lazy evaluation
        self.columns = @core.columns._inheritable
        self.columns.exclude :created_on, :created_at, :updated_on, :updated_at
        self.columns.exclude *@core.columns.collect{|c| c.name if c.polymorphic_association?}.compact
      end
      @columns
    end
    
    public :columns=
    
    # whether the form should be multipart
    attr_writer :multipart
    def multipart?
      @multipart ? true : false
    end
  end
end
