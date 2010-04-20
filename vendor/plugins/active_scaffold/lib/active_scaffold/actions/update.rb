module ActiveScaffold::Actions
  module Update
    def self.included(base)
      base.before_filter :update_authorized_filter, :only => [:edit, :update]
      base.verify :method => [:post, :put],
                  :only => :update,
                  :redirect_to => { :action => :index }
    end

    def edit
      do_edit
      respond_to_action(:edit)
    end

    def update
      do_update
      respond_to_action(:update)
    end

    # for inline (inlist) editing
    def update_column
      do_update_column
      render :action => 'update_column'
    end

    protected
    def edit_respond_to_html
      if successful?
        render(:action => 'update')
      else
        return_to_main
      end
    end
    def edit_respond_to_js
      render(:partial => 'update_form')
    end
    def update_respond_to_html  
      if params[:iframe]=='true' # was this an iframe post ?
        responds_to_parent do
          render :action => 'on_update.js'
        end
      else # just a regular post
        if successful?
          flash[:info] = as_(:updated_model, :model => @record.to_label)
          return_to_main
        else
          render(:action => 'update')
        end
      end
    end
    def update_respond_to_js
      render :action => 'on_update'
    end
    def update_respond_to_xml
      render :xml => response_object.to_xml(:only => active_scaffold_config.update.columns.names), :content_type => Mime::XML, :status => response_status
    end
    def update_respond_to_json
      render :text => response_object.to_json(:only => active_scaffold_config.update.columns.names), :content_type => Mime::JSON, :status => response_status
    end
    def update_respond_to_yaml
      render :text => Hash.from_xml(response_object.to_xml(:only => active_scaffold_config.update.columns.names)).to_yaml, :content_type => Mime::YAML, :status => response_status
    end
    # A simple method to find and prepare a record for editing
    # May be overridden to customize the record (set default values, etc.)
    def do_edit
      @record = find_if_allowed(params[:id], :update)
    end

    # A complex method to update a record. The complexity comes from the support for subforms, and saving associated records.
    # If you want to customize this algorithm, consider using the +before_update_save+ callback
    def do_update
      do_edit
      begin
        active_scaffold_config.model.transaction do
          @record = update_record_from_params(@record, active_scaffold_config.update.columns, params[:record])
          before_update_save(@record)
          self.successful = [@record.valid?, @record.associated_valid?].all? {|v| v == true} # this syntax avoids a short-circuit
          if successful?
            @record.save! and @record.save_associated!
            after_update_save(@record)
          end
        end
      rescue ActiveRecord::RecordInvalid
      rescue ActiveRecord::StaleObjectError
        @record.errors.add_to_base as_(:version_inconsistency)
        self.successful=false
      rescue ActiveRecord::RecordNotSaved
        @record.errors.add_to_base as_("Failed to save record cause of an unknown error") if @record.errors.empty?
        self.successful = false
      end
    end

    def do_update_column
      @record = active_scaffold_config.model.find(params[:id])
      if @record.authorized_for?(:crud_type => :update, :column => params[:column])
        column = active_scaffold_config.columns[params[:column].to_sym]
        params[:value] ||= @record.column_for_attribute(params[:column]).default unless @record.column_for_attribute(params[:column]).nil? || @record.column_for_attribute(params[:column]).null
        params[:value] = column_value_from_param_value(@record, column, params[:value]) unless column.nil?
        @record.send("#{params[:column]}=", params[:value])
        before_update_save(@record)
        @record.save
        after_update_save(@record)
      end
    end

    # override this method if you want to inject data in the record (or its associated objects) before the save
    def before_update_save(record); end

    # override this method if you want to do something after the save
    def after_update_save(record); end

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def update_authorized?
      authorized_for?(:crud_type => :update)
    end
    private
    def update_authorized_filter
      link = active_scaffold_config.update.link || active_scaffold_config.update.class.link
      raise ActiveScaffold::ActionNotAllowed unless self.send(link.security_method)
    end
    def edit_formats
      (default_formats + active_scaffold_config.formats).uniq
    end
    def update_formats
      (default_formats + active_scaffold_config.formats + active_scaffold_config.update.formats).uniq
    end
  end
end
