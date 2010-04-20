module ActiveScaffold::Config
  class Core < Base
    # global level configuration
    # --------------------------

    # provides read/write access to the global Actions DataStructure
    cattr_reader :actions
    def self.actions=(val)
      @@actions = ActiveScaffold::DataStructures::Actions.new(*val)
    end
    self.actions = [:create, :list, :search, :update, :delete, :show, :nested, :subform]

    # configures where the ActiveScaffold plugin itself is located. there is no instance version of this.
    cattr_accessor :plugin_directory
    @@plugin_directory = File.expand_path(__FILE__).match(/vendor\/plugins\/([^\/]*)/)[1]

    # lets you specify a global ActiveScaffold frontend.
    cattr_accessor :frontend
    @@frontend = :default

    # lets you specify a global ActiveScaffold theme for your frontend.
    cattr_accessor :theme
    @@theme = :default

    # lets you disable the DHTML history
    def self.dhtml_history=(val)
      @@dhtml_history = val
    end
    def self.dhtml_history?
      @@dhtml_history ? true : false
    end
    @@dhtml_history = true

    # action links are used by actions to tie together. you can use them, too! this is a collection of ActiveScaffold::DataStructures::ActionLink objects.
    cattr_reader :action_links
    @@action_links = ActiveScaffold::DataStructures::ActionLinks.new

    # access to the permissions configuration.
    # configuration options include:
    #  * current_user_method - what method on the controller returns the current user. default: :current_user
    #  * default_permission - what the default permission is. default: true
    def self.security
      ActiveRecordPermissions
    end

    # columns that should be ignored for every model. these should be metadata columns like change dates, versions, etc.
    # values in this array may be symbols or strings.
    def self.ignore_columns
      @@ignore_columns
    end
    def self.ignore_columns=(val)
      @@ignore_columns = ActiveScaffold::DataStructures::Set.new(*val)
    end
    @@ignore_columns = ActiveScaffold::DataStructures::Set.new

    # lets you specify whether add a create link for each sti child
    cattr_accessor :sti_create_links

    # instance-level configuration
    # ----------------------------

    # provides read/write access to the local Actions DataStructure
    attr_reader :actions
    def actions=(args)
      @actions = ActiveScaffold::DataStructures::Actions.new(*args)
    end

    # provides read/write access to the local Columns DataStructure
    attr_reader :columns
    def columns=(val)
      @columns._inheritable = val.collect {|c| c.to_sym}
      # Add virtual columns
      @columns << val.collect {|c| c.to_sym unless @columns[c.to_sym]}.compact
    end

    # lets you override the global ActiveScaffold frontend for a specific controller
    attr_accessor :frontend

    # lets you override the global ActiveScaffold theme for a specific controller
    attr_accessor :theme

    # lets you specify whether add a create link for each sti child for a specific controller
    attr_accessor :sti_create_links
    def add_sti_create_links?
      self.sti_create_links and not self.sti_children.nil?
    end

    # action links are used by actions to tie together. they appear as links for each record, or general links for the ActiveScaffold.
    attr_reader :action_links

    # a generally-applicable name for this ActiveScaffold ... will be used for generating page/section headers
    attr_writer :label
    def label(options={})
      as_(@label, options) || model.human_name(options.merge(options[:count].to_i == 1 ? {} : {:default => model.name.pluralize}))
    end

    # STI children models, use an array of model names
    attr_accessor :sti_children

    ##
    ## internal usage only below this point
    ## ------------------------------------

    def initialize(model_id)
      # model_id is the only absolutely required configuration value. it is also not publicly accessible.
      @model_id = model_id.to_s.pluralize.singularize

      # inherit the actions list directly from the global level
      @actions = self.class.actions.clone

      # create a new default columns datastructure, since it doesn't make sense before now
      attribute_names = self.model.columns.collect{ |c| c.name.to_sym }.sort_by { |c| c.to_s }
      association_column_names = self.model.reflect_on_all_associations.collect{ |a| a.name.to_sym }.sort_by { |c| c.to_s }
      @columns = ActiveScaffold::DataStructures::Columns.new(self.model, attribute_names + association_column_names)

      # and then, let's remove some columns from the inheritable set.
      @columns.exclude(*self.class.ignore_columns)
      @columns.exclude(*@columns.find_all { |c| c.column and (c.column.primary or c.column.name =~ /(_id|_count)$/) }.collect {|c| c.name})
      @columns.exclude(*self.model.reflect_on_all_associations.collect{|a| :"#{a.name}_type" if a.options[:polymorphic]}.compact)

      # inherit the global frontend
      @frontend = self.class.frontend
      @theme = self.class.theme
      @sti_create_links = self.class.sti_create_links

      # inherit from the global set of action links
      @action_links = self.class.action_links.clone
    end

    # To be called after your finished configuration
    def _load_action_columns
      ActiveScaffold::DataStructures::ActionColumns.class_eval {include ActiveScaffold::DataStructures::ActionColumns::AfterConfiguration}

      # then, register the column objects
      self.actions.each do |action_name|
        action = self.send(action_name)
        next unless action.respond_to? :columns
        action.columns.set_columns(self.columns)
      end
    end

    # To be called after your finished configuration
    def _configure_sti
      column = self.model.inheritance_column
      if sti_create_links
        self.columns[column].form_ui ||= :hidden
      else
        self.columns[column].form_ui ||= :select
        self.columns[column].options ||= {}
        self.columns[column].options[:options] = self.sti_children.collect do |model_name|
          [model_name.to_s.camelize.constantize.human_name, model_name.to_s.camelize]
        end
      end
    end

    # To be called after include action modules
    def _add_sti_create_links
      new_action_link = @action_links['new']
      unless new_action_link.nil?
        @action_links.delete('new')
        self.sti_children.each do |child| 
          new_sti_link = Marshal.load(Marshal.dump(new_action_link)) # deep clone
          new_sti_link.label = as_(:create_model, :model => child.to_s.camelize.constantize.human_name)
          new_sti_link.parameters = {model.inheritance_column => child}
          @action_links.add(new_sti_link)
        end
      end
    end

    # configuration routing.
    # we want to route calls named like an activated action to that action's global or local Config class.
    # ---------------------------
    def method_missing(name, *args)
      @action_configs ||= {}
      titled_name = name.to_s.camelcase
      underscored_name = name.to_s.underscore.to_sym
      klass = "ActiveScaffold::Config::#{titled_name}".constantize rescue nil
      if klass
        if @actions.include? underscored_name
          return @action_configs[underscored_name] ||= klass.new(self)
        else
          raise "#{titled_name} is not enabled. Please enable it or remove any references in your configuration (e.g. config.#{underscored_name}.columns = [...])."
        end
      end
      super
    end

    def self.method_missing(name, *args)
      klass = "ActiveScaffold::Config::#{name.to_s.titleize}".constantize rescue nil
      if @@actions.include? name.to_s.underscore and klass
        return eval("ActiveScaffold::Config::#{name.to_s.titleize}")
      end
      super
    end
    # some utility methods
    # --------------------

    def model_id
      @model_id
    end

    def model
      @model ||= @model_id.to_s.camelize.constantize
    end

    # warning - this won't work as a per-request dynamic attribute in rails 2.0.  You'll need to interact with Controller#generic_view_paths
    def inherited_view_paths
      @inherited_view_paths||=[]
    end

    # must be a class method so the layout doesn't depend on a controller that uses active_scaffold
    # note that this is unaffected by per-controller frontend configuration.
    def self.asset_path(filename, frontend = self.frontend)
      "active_scaffold/#{frontend}/#{filename}"
    end

    # must be a class method so the layout doesn't depend on a controller that uses active_scaffold
    # note that this is unaffected by per-controller frontend configuration.
    def self.javascripts(frontend = self.frontend)
      javascript_dir = File.join(Rails.public_path, "javascripts", asset_path('', frontend))
      Dir.entries(javascript_dir).reject { |e| !e.match(/\.js$/) or (!self.dhtml_history? and e.match('dhtml_history')) }
    end

    def self.available_frontends
      frontends_dir = File.join(Rails.root, "vendor", "plugins", ActiveScaffold::Config::Core.plugin_directory, "frontends")
      Dir.entries(frontends_dir).reject { |e| e.match(/^\./) } # Get rid of files that start with .
    end
  end
end
