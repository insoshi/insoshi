module ActiveScaffold::Config
  class Delete < Base
    self.crud_type = :destroy

    def initialize(core_config)
      @core = core_config

      # start with the ActionLink defined globally
      @link = self.class.link.clone
    end

    # global level configuration
    # --------------------------

    # the ActionLink for this action
    cattr_accessor :link
    @@link = ActiveScaffold::DataStructures::ActionLink.new('destroy', :label => 'Delete', :type => :record, :confirm => 'Are you sure?', :method => :delete, :position => false, :security_method => :delete_authorized?)

    # instance-level configuration
    # ----------------------------

    # the ActionLink for this action
    attr_accessor :link
  end
end