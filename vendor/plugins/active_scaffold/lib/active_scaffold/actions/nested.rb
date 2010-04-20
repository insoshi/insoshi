module ActiveScaffold::Actions
  # The Nested module basically handles automatically linking controllers together. It does this by creating column links with the right parameters, and by providing any supporting systems (like a /:controller/nested action for returning associated scaffolds).
  module Nested

    def self.included(base)
      super
      base.module_eval do
        include ActiveScaffold::Actions::Nested::ChildMethods if active_scaffold_config.model.reflect_on_all_associations.any? {|a| a.macro == :has_and_belongs_to_many}
      end
      base.before_filter :include_habtm_actions
      base.helper_method :nested_habtm?
    end

    def nested
      do_nested
      respond_to_action(:nested)
    end

    protected
    def nested_respond_to_html
      render :partial => 'nested', :layout => true
    end
    def nested_respond_to_js
      render :partial => 'nested'
    end
    # A simple method to find the record we'll be nesting *from*
    # May be overridden to customize the behavior
    def do_nested
      @record = find_if_allowed(params[:id], :read)
    end

    def nested_authorized?
      true
    end

    def include_habtm_actions
      if nested_habtm?
        # Production mode is ok with adding a link everytime the scaffold is nested - we ar not ok with that.
        active_scaffold_config.action_links.add('new_existing', :label => :add_existing, :type => :collection, :security_method => :add_existing_authorized?) unless active_scaffold_config.action_links['new_existing']
        if active_scaffold_config.nested.shallow_delete
          active_scaffold_config.action_links.add('destroy_existing', :label => :remove, :type => :member, :confirm => :are_you_sure_to_delete, :method => :delete, :position => false, :security_method => :delete_existing_authorized?) unless active_scaffold_config.action_links['destroy_existing']
          active_scaffold_config.action_links.delete("delete") if active_scaffold_config.action_links['delete']
        end
      else
        # Production mode is caching this link into a non nested scaffold
        active_scaffold_config.action_links.delete('new_existing') if active_scaffold_config.action_links['new_existing']
        
        if active_scaffold_config.nested.shallow_delete
          active_scaffold_config.action_links.delete("destroy_existing") if active_scaffold_config.action_links['destroy_existing']
          active_scaffold_config.action_links.add(ActiveScaffold::Config::Delete.link) unless active_scaffold_config.action_links['delete']
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
    private
    def nested_formats
      (default_formats + active_scaffold_config.formats + active_scaffold_config.nested.formats).uniq
    end
  end
end

module ActiveScaffold::Actions::Nested
  module ChildMethods

    def self.included(base)
      super
      base.verify :method => :post,
                  :only => :add_existing,
                  :redirect_to => { :action => :index }
    end

    def new_existing
      do_new
      respond_to_action(:new_existing)
    end

    def add_existing
      do_add_existing
      respond_to_action(:add_existing)
    end

    def destroy_existing
      return redirect_to(params.merge(:action => :delete)) if request.get?
      do_destroy_existing
      respond_to_action(:destroy_existing)
    end
    
    protected
    def new_existing_respond_to_html
      if successful?
        render(:action => 'add_existing_form')
      else
        return_to_main
      end
    end
    def new_existing_respond_to_js
      render(:partial => 'add_existing_form')
    end
    def add_existing_respond_to_html
      if successful?
        flash[:info] = as_(:created_model, :model => @record.to_label)
        return_to_main
      else
        render(:action => 'add_existing_form')
      end
    end
    def add_existing_respond_to_js
      if successful?
        render :action => 'add_existing'
      else
        render :action => 'form_messages'
      end
    end
    def add_existing_respond_to_xml
      render :xml => response_object.to_xml(:only => active_scaffold_config.list.columns.names), :content_type => Mime::XML, :status => response_status
    end
    def add_existing_respond_to_json
      render :text => response_object.to_json(:only => active_scaffold_config.list.columns.names), :content_type => Mime::JSON, :status => response_status
    end
    def add_existing_respond_to_yaml
      render :text => Hash.from_xml(response_object.to_xml(:only => active_scaffold_config.list.columns.names)).to_yaml, :content_type => Mime::YAML, :status => response_status
    end
    def destroy_existing_respond_to_html
      flash[:info] = as_(:deleted_model, :model => @record.to_label)
      return_to_main
    end

    def destroy_existing_respond_to_js
      render(:action => 'destroy')
    end

    def destroy_existing_respond_to_xml
      render :xml => successful? ? "" : response_object.to_xml(:only => active_scaffold_config.list.columns.names), :content_type => Mime::XML, :status => response_status
    end

    def destroy_existing_respond_to_json
      render :text => successful? ? "" : response_object.to_json(:only => active_scaffold_config.list.columns.names), :content_type => Mime::JSON, :status => response_status
    end

    def destroy_existing_respond_to_yaml
      render :text => successful? ? "" : Hash.from_xml(response_object.to_xml(:only => active_scaffold_config.list.columns.names)).to_yaml, :content_type => Mime::YAML, :status => response_status
    end

    def add_existing_authorized?
      true
    end
    def delete_existing_authorized?
      true
    end
 
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
    private
    def new_existing_formats
      (default_formats + active_scaffold_config.formats).uniq
    end
    def add_existing_formats
      (default_formats + active_scaffold_config.formats).uniq
    end
    def destroy_existing_formats
      (default_formats + active_scaffold_config.formats).uniq
    end
  end
end
