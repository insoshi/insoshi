module ActiveScaffold::Config
  class FieldSearch < Base
    self.crud_type = :read

    def initialize(core_config)
      @core = core_config

      @full_text_search = self.class.full_text_search?

      # start with the ActionLink defined globally
      @link = self.class.link.clone
    end


    # global level configuration
    # --------------------------
    # the ActionLink for this action
    cattr_reader :link
    @@link = ActiveScaffold::DataStructures::ActionLink.new('show_search', :label => 'Search', :type => :table, :security_method => :search_authorized?)

    cattr_writer :full_text_search
    def self.full_text_search?
      @@full_text_search
    end
    @@full_text_search = true

    # instance-level configuration
    # ----------------------------

    # provides access to the list of columns specifically meant for the Search to use
    def columns
      # we want to delay initializing to the @core.columns set for as long as possible. Too soon and .search_sql will not be available to .searchable?
      unless @columns
        self.columns = @core.columns._inheritable
        self.columns.exclude @core.columns.active_record_class.locking_column.to_sym
      end
      @columns
    end

    def columns=(val)
      @columns = ActiveScaffold::DataStructures::ActionColumns.new(*val)
      @columns.action = self
    end

    attr_writer :full_text_search
    def full_text_search?
      @full_text_search
    end

    # the ActionLink for this action
    attr_accessor :link
  end
end
