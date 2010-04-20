module ActiveScaffold::Config
  class Delete < Base
    self.crud_type = :delete

    def initialize(core_config)
      @core = core_config

      # start with the ActionLink defined globally
      @link = self.class.link.clone
    end

    # global level configuration
    # --------------------------

    # the ActionLink for this action
    cattr_accessor :link
    @@link = ActiveScaffold::DataStructures::ActionLink.new('delete', :label => :delete, :type => :member, :confirm => :are_you_sure_to_delete, :crud_type => :delete, :method => :delete, :position => false, :security_method => :delete_authorized?)

    # instance-level configuration
    # ----------------------------

    # the ActionLink for this action
    attr_accessor :link
  end
end
