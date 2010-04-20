module ActiveScaffold
  class ControllerNotFound < RuntimeError; end
  class DependencyFailure < RuntimeError; end
  class MalformedConstraint < RuntimeError; end
  class RecordNotAllowed < SecurityError; end
  class ActionNotAllowed < SecurityError; end
  class ReverseAssociationRequired < RuntimeError; end

  def self.included(base)
    base.extend(ClassMethods)
    base.module_eval do
      # TODO: these should be in actions/core
      before_filter :handle_user_settings
    end
  end

  def self.set_defaults(&block)
    ActiveScaffold::Config::Core.configure &block
  end

  def active_scaffold_config
    self.class.active_scaffold_config
  end

  def active_scaffold_config_for(klass)
    self.class.active_scaffold_config_for(klass)
  end

  def active_scaffold_session_storage
    id = params[:eid] || params[:controller]
    session_index = "as:#{id}"
    session[session_index] ||= {}
    session[session_index]
  end

  # at some point we need to pass the session and params into config. we'll just take care of that before any particular action occurs by passing those hashes off to the UserSettings class of each action.
  def handle_user_settings
    if self.class.uses_active_scaffold?
      active_scaffold_config.actions.each do |action_name|
        conf_instance = active_scaffold_config.send(action_name) rescue next
        next if conf_instance.class::UserSettings == ActiveScaffold::Config::Base::UserSettings # if it hasn't been extended, skip it
        active_scaffold_session_storage[action_name] ||= {}
        conf_instance.user = conf_instance.class::UserSettings.new(conf_instance, active_scaffold_session_storage[action_name], params)
      end
    end
  end

  module ClassMethods
    def active_scaffold(model_id = nil, &block)
      # initialize bridges here
      ActiveScaffold::Bridge.run_all

      # converts Foo::BarController to 'bar' and FooBarsController to 'foo_bar' and AddressController to 'address'
      model_id = self.to_s.split('::').last.sub(/Controller$/, '').pluralize.singularize.underscore unless model_id

      # run the configuration
      @active_scaffold_config = ActiveScaffold::Config::Core.new(model_id)
      @active_scaffold_config_block = block
      self.links_for_associations

      @active_scaffold_overrides = []
      ActionController::Base.view_paths.each do |dir|
        active_scaffold_overrides_dir = File.join(dir,"active_scaffold_overrides")
        @active_scaffold_overrides << active_scaffold_overrides_dir if File.exists?(active_scaffold_overrides_dir)
      end
      @active_scaffold_overrides.uniq! # Fix rails duplicating some view_paths
      @active_scaffold_frontends = []
      if active_scaffold_config.frontend.to_sym != :default
        active_scaffold_custom_frontend_path = File.join(Rails.root, 'vendor', 'plugins', ActiveScaffold::Config::Core.plugin_directory, 'frontends', active_scaffold_config.frontend.to_s , 'views')
        @active_scaffold_frontends << active_scaffold_custom_frontend_path
      end
      active_scaffold_default_frontend_path = File.join(Rails.root, 'vendor', 'plugins', ActiveScaffold::Config::Core.plugin_directory, 'frontends', 'default' , 'views')
      @active_scaffold_frontends << active_scaffold_default_frontend_path
      @active_scaffold_custom_paths = []

      self.active_scaffold_superclasses_blocks.each {|superblock| self.active_scaffold_config.configure &superblock}
      self.active_scaffold_config.configure &block if block_given?
      self.active_scaffold_config._configure_sti unless self.active_scaffold_config.sti_children.nil?
      self.active_scaffold_config._load_action_columns

      # defines the attribute read methods on the model, so record.send() doesn't find protected/private methods instead
      klass = self.active_scaffold_config.model
      klass.define_attribute_methods unless klass.generated_methods?

      # include the rest of the code into the controller: the action core and the included actions
      module_eval do
        include ActiveScaffold::Finder
        include ActiveScaffold::Constraints
        include ActiveScaffold::AttributeParams
        include ActiveScaffold::Actions::Core
        active_scaffold_config.actions.each do |mod|
          name = mod.to_s.camelize
          include "ActiveScaffold::Actions::#{name}".constantize

          # sneak the action links from the actions into the main set
          if link = active_scaffold_config.send(mod).link rescue nil
            active_scaffold_config.action_links << link
          end
        end
      end
      self.active_scaffold_config._add_sti_create_links if self.active_scaffold_config.add_sti_create_links?
    end

    # Create the automatic column links. Note that this has to happen when configuration is *done*, because otherwise the Nested module could be disabled. Actually, it could still be disabled later, couldn't it?
    def links_for_associations
      return unless active_scaffold_config.actions.include? :list and active_scaffold_config.actions.include? :nested
      active_scaffold_config.columns.each do |column|
        next unless column.link.nil? and column.autolink?
        if column.plural_association?
          # note: we can't create nested scaffolds on :through associations because there's no reverse association.
          column.set_link('nested', :parameters => {:associations => column.name.to_sym}, :html_options => {:class => column.name}) #unless column.through_association?
        elsif column.polymorphic_association?
          # note: we can't create inline forms on singular polymorphic associations
          column.clear_link
        else
          model = column.association.klass
          begin
            controller = active_scaffold_controller_for(model)
          rescue ActiveScaffold::ControllerNotFound
            next
          end

          actions = controller.active_scaffold_config.actions
          column.actions_for_association_links.delete :new unless actions.include? :create
          column.actions_for_association_links.delete :edit unless actions.include? :update
          column.actions_for_association_links.delete :show unless actions.include? :show
          column.set_link(:none, :controller => controller.controller_path, :crud_type => nil, :html_options => {:class => column.name})
        end
      end
    end

    def add_active_scaffold_path(path)
      @active_scaffold_paths = nil # Force active_scaffold_paths to rebuild
      @active_scaffold_custom_paths << path
    end

    def add_active_scaffold_override_path(path)
      @active_scaffold_paths = nil # Force active_scaffold_paths to rebuild
      @active_scaffold_overrides.unshift path
    end

    def active_scaffold_paths
      return @active_scaffold_paths unless @active_scaffold_paths.nil?

      @active_scaffold_paths = ActionView::PathSet.new
      @active_scaffold_paths.concat @active_scaffold_overrides unless @active_scaffold_overrides.nil?
      @active_scaffold_paths.concat @active_scaffold_custom_paths unless @active_scaffold_custom_paths.nil?
      @active_scaffold_paths.concat @active_scaffold_frontends unless @active_scaffold_frontends.nil?
      @active_scaffold_paths
    end

    def active_scaffold_config
      if @active_scaffold_config.nil?
        self.superclass.active_scaffold_config if self.superclass.respond_to? :active_scaffold_config
      else
        @active_scaffold_config
      end
    end

    def active_scaffold_config_block
      @active_scaffold_config_block
    end

    def active_scaffold_superclasses_blocks
      blocks = []
      klass = self.superclass
      while klass.respond_to? :active_scaffold_superclasses_blocks
        blocks << klass.active_scaffold_config_block
        klass = klass.superclass
      end
      blocks.compact.reverse
    end

    def active_scaffold_config_for(klass)
      begin
        controller = active_scaffold_controller_for(klass)
      rescue ActiveScaffold::ControllerNotFound
        config = ActiveScaffold::Config::Core.new(klass)
        config._load_action_columns
        config
      else
        controller.active_scaffold_config
      end
    end

    # Tries to find a controller for the given ActiveRecord model.
    # Searches in the namespace of the current controller for singular and plural versions of the conventional "#{model}Controller" syntax.
    # You may override this method to customize the search routine.
    def active_scaffold_controller_for(klass)
      controller_namespace = self.to_s.split('::')[0...-1].join('::') + '::'
      error_message = []
      [controller_namespace, ''].each do |namespace|
        ["#{klass.to_s.underscore.pluralize}", "#{klass.to_s.underscore.pluralize.singularize}"].each do |controller_name|
          begin
            controller = "#{namespace}#{controller_name.camelize}Controller".constantize
          rescue NameError => error
            # Only rescue NameError associated with the controller constant not existing - not other compile errors
            if error.message["uninitialized constant #{controller}"]
              error_message << "#{namespace}#{controller_name.camelize}Controller"
              next
            else
              raise
            end
          end
          raise ActiveScaffold::ControllerNotFound, "#{controller} missing ActiveScaffold", caller unless controller.uses_active_scaffold?
          raise ActiveScaffold::ControllerNotFound, "ActiveScaffold on #{controller} is not for #{klass} model.", caller unless controller.active_scaffold_config.model == klass
          return controller
        end
      end
      raise ActiveScaffold::ControllerNotFound, "Could not find " + error_message.join(" or "), caller
    end

    def uses_active_scaffold?
      !active_scaffold_config.nil?
    end
  end
end
