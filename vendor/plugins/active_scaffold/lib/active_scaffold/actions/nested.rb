module ActiveScaffold::Actions
  # The Nested module basically handles automatically linking controllers together. It does this by creating column links with the right parameters, and by providing any supporting systems (like a /:controller/nested action for returning associated scaffolds).
  module Nested

    def self.included(base)
      super
      base.before_filter :include_habtm_actions
      # TODO: it's a bit wasteful to run this routine every page load.
      base.before_filter :links_for_associations
      base.helper_method :nested_habtm?
    end

    def nested
      do_nested

      respond_to do |type|
        type.html { render :partial => 'nested', :layout => true }
        type.js { render :partial => 'nested', :layout => false }
      end
    end

    protected

    # A simple method to find the record we'll be nesting *from*
    # May be overridden to customize the behavior
    def do_nested
      @record = find_if_allowed(params[:id], :read)
    end

    # Create the automatic column links. Note that this has to happen when configuration is *done*, because otherwise the Nested module could be disabled. Actually, it could still be disabled later, couldn't it?
    # TODO: This should really be a post-config routine, instead of a before_filter.
    def links_for_associations
      active_scaffold_config.list.columns.each do |column|
        # if column.link == false we won't create a link. that's how a dev can suppress the auto links.
        if column.association and column.link.nil?
          if column.plural_association?
            # note: we can't create nested scaffolds on :through associations because there's no reverse association.
            column.set_link('nested', :parameters => {:associations => column.name.to_sym}) #unless column.through_association?
          elsif not column.polymorphic_association?
            model = column.association.klass
            begin
              controller = self.class.active_scaffold_controller_for(model)
            rescue ActiveScaffold::ControllerNotFound
              next
            end

            actions = controller.active_scaffold_config.actions
            action = nil
            if actions.include? :update and column.actions_for_association_links.include? :edit
              action = 'edit'
            elsif actions.include? :show and column.actions_for_association_links.include? :show
              action = 'show'
            end
            column.set_link(action, :controller => controller.controller_path, :parameters => {:parent_controller => params[:controller]}) if action
          end
        end
      end
    end

    def include_habtm_actions
      if nested_habtm?
        # Production mode is ok with adding a link everytime the scaffold is nested - we ar not ok with that.
        active_scaffold_config.action_links.add('new_existing', :label => :add_existing, :type => :table, :security_method => :add_existing_authorized?) unless active_scaffold_config.action_links['new_existing']
        if active_scaffold_config.nested.shallow_delete
          active_scaffold_config.action_links.add('destroy_existing', :label => :remove, :type => :record, :confirm => 'are_you_sure', :method => :delete, :position => false, :security_method => :delete_existing_authorized?) unless active_scaffold_config.action_links['destroy_existing']
          active_scaffold_config.action_links.delete("destroy") if active_scaffold_config.action_links['destroy']
        end
        
        self.class.module_eval do
          include ActiveScaffold::Actions::Nested::ChildMethods
          # we need specifically to tell action_controller to add these public methods as action_methods
          ActiveScaffold::Actions::Nested::ChildMethods.public_instance_methods.each{|m| self.action_methods.add m }
        end unless self.class.included_modules.include?(ActiveScaffold::Actions::Nested::ChildMethods)
      else
        # Production mode is caching this link into a non nested scaffold
        active_scaffold_config.action_links.delete('new_existing') if active_scaffold_config.action_links['new_existing']
        
        if active_scaffold_config.nested.shallow_delete
          active_scaffold_config.action_links.delete("destroy_existing") if active_scaffold_config.action_links['destroy_existing']
          active_scaffold_config.action_links.add('destroy', :label => :delete, :type => :record, :confirm => 'are_you_sure', :method => :delete, :position => false, :security_method => :delete_authorized?) unless active_scaffold_config.action_links['destroy']
        end
        
      end
    end

    def nested?
      !params[:nested].nil?
    end

    def nested_habtm?
      begin
        a = active_scaffold_config.columns[nested_association]
        return a.association.macro == :has_and_belongs_to_many if a and nested?
        false
      rescue
        raise ActiveScaffold::MalformedConstraint, constraint_error(active_scaffold_config.model, nested_association), caller
      end
    end

    def nested_association
      return active_scaffold_constraints.keys.to_s.to_sym if nested?
      nil
    end

    def nested_parent_id
      return active_scaffold_constraints.values.to_s if nested?
      nil
    end

  end
end

module ActiveScaffold::Actions::Nested
  module ChildMethods

    def self.included(base)
      super
      # This .verify method call is clashing with other non .add_existing actions. How do we do this correctly? Can we make it action specific.
      # base.verify :method => :post,
      #             :only => :add_existing,
      #             :redirect_to => { :action => :index }
    end

    def new_existing
      do_new

      respond_to do |type|
        type.html do
          if successful?
            render(:action => 'add_existing_form', :layout => true)
          else
            return_to_main
          end
        end
        type.js do
          render(:partial => 'add_existing_form.rhtml', :layout => false)
        end
      end
    end

    def add_existing
      do_add_existing

      respond_to do |type|
        type.html do
          if successful?
            flash[:info] = as_(:created_model, :model => @record.to_label)
            return_to_main
          else
            render(:action => 'add_existing_form', :layout => true)
          end
        end
        type.js do
          if successful?
            render :action => 'add_existing', :layout => false
          else
            render :action => 'form_messages.rjs', :layout => false
          end
        end
        type.xml { render :xml => response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.json { render :text => response_object.to_json, :content_type => Mime::JSON, :status => response_status }
        type.yaml { render :text => response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end

    def destroy_existing
      return redirect_to(params.merge(:action => :delete)) if request.get?

      do_destroy_existing

      respond_to do |type|
        type.html do
          flash[:info] = as_(:deleted_model, :model => @record.to_label)
          return_to_main
        end
        type.js { render(:action => 'destroy.rjs', :layout => false) }
        type.xml { render :xml => successful? ? "" : response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.json { render :text => successful? ? "" : response_object.to_json, :content_type => Mime::JSON, :status => response_status }
        type.yaml { render :text => successful? ? "" : response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end
    
    protected

    def after_create_save(record)
      if params[:association_macro] == :has_and_belongs_to_many
        params[:associated_id] = record
        do_add_existing
      end
    end

    def nested_action_from_params
      return params[:parent_model].constantize, nested_parent_id, params[:parent_column]
    end

    # The actual "add_existing" algorithm
    def do_add_existing
      parent_model, id, association = nested_action_from_params
      parent_record = find_if_allowed(id, :update, parent_model)
      @record = active_scaffold_config.model.find(params[:associated_id])
      parent_record.send(association) << @record
      parent_record.save
    end

    def do_destroy_existing
      if active_scaffold_config.nested.shallow_delete
        parent_model, id, association = nested_action_from_params
        @record = find_if_allowed(id, :update, parent_model)
        collection = @record.send(association)
        assoc_record = collection.find(params[:id])
        collection.delete(assoc_record)
      else
        do_destroy
      end
    end

  end
end
