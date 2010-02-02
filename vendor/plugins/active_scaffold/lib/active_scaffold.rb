module ActiveScaffold
  class ControllerNotFound < RuntimeError; end
  class DependencyFailure < RuntimeError; end
  class MalformedConstraint < RuntimeError; end
  class RecordNotAllowed < SecurityError; end
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
      self.active_scaffold_config.configure &block if block_given?
      self.active_scaffold_config._load_action_columns

      # defines the attribute read methods on the model, so record.send() doesn't find protected/private methods instead
      klass = self.active_scaffold_config.model
      klass.define_attribute_methods unless klass.generated_methods?

      ActionController::Base.view_paths.each do |dir|
        self.append_view_path(File.join(dir,"active_scaffold_overrides")) if File.exists?(File.join(dir,"active_scaffold_overrides"))
      end
      if active_scaffold_config.frontend.to_sym != :default
        self.append_view_path(File.join(Rails.root, 'vendor', 'plugins', ActiveScaffold::Config::Core.plugin_directory, 'frontends', active_scaffold_config.frontend.to_s , 'views'))
      end
      self.append_view_path(File.join(Rails.root, 'vendor', 'plugins', ActiveScaffold::Config::Core.plugin_directory, 'frontends', 'default' , 'views'))

      # include the rest of the code into the controller: the action core and the included actions
      module_eval do
        include ActiveScaffold::Finder
        include ActiveScaffold::Constraints
        include ActiveScaffold::AttributeParams
        include ActiveScaffold::Actions::Core
        active_scaffold_config.actions.each do |mod|
          name = mod.to_s.camelize
          include "ActiveScaffold::Actions::#{name}".constantize rescue nil

          # sneak the action links from the actions into the main set
          if link = active_scaffold_config.send(mod).link rescue nil
            active_scaffold_config.action_links << link
          end
        end
      end
    end

    def active_scaffold_config
       @active_scaffold_config || self.superclass.instance_variable_get('@active_scaffold_config')
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
      namespace = self.to_s.split('::')[0...-1].join('::') + '::'
      error_message = []
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
      raise ActiveScaffold::ControllerNotFound, "Could not find " + error_message.join(" or "), caller
    end

    def uses_active_scaffold?
      !active_scaffold_config.nil?
    end
  end
end
