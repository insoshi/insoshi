module ActiveScaffold::Actions
  module Update
    def self.included(base)
      base.before_filter :update_authorized?, :only => [:edit, :update]
      base.verify :method => [:post, :put],
                  :only => :update,
                  :redirect_to => { :action => :index }
    end

    def edit
      do_edit

      respond_to do |type|
        type.html do
          if successful?
            render(:action => 'update_form', :layout => true)
          else
            return_to_main
          end
        end
        type.js do
          render(:partial => 'update_form', :layout => false)
        end
      end
    end

    def update
      do_update

      respond_to do |type|
        type.html do
          if params[:iframe]=='true' # was this an iframe post ?
            responds_to_parent do
              if successful?
                render :action => 'update.rjs', :layout => false
              else
                render :action => 'form_messages.rjs', :layout => false
              end
            end
          else # just a regular post
            if successful?
              flash[:info] = as_('Updated %s', @record.to_label)
              return_to_main
            else
              render(:action => 'update_form', :layout => true)
            end
          end
        end
        type.js do
          render :action => 'update.rjs', :layout => false
        end
        type.xml { render :xml => response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.json { render :text => response_object.to_json, :content_type => Mime::JSON, :status => response_status }
        type.yaml { render :text => response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end

    # for inline (inlist) editing
    def update_column
      do_update_column
      render :action => 'update_column.rjs', :layout => false
    end

    protected

    # A simple method to find and prepare a record for editing
    # May be overridden to customize the record (set default values, etc.)
    def do_edit
      @record = find_if_allowed(params[:id], :update)
    end

    # A complex method to update a record. The complexity comes from the support for subforms, and saving associated records.
    # If you want to customize this algorithm, consider using the +before_update_save+ callback
    def do_update
      @record = find_if_allowed(params[:id], :update)
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
        @record.errors.add_to_base as_("Version inconsistency - this record has been modified since you started editing it.")
        self.successful=false
      end
    end

    def do_update_column
      @record = find_if_allowed(params[:id], :update)
      if @record.authorized_for?(:action => :update, :column => params[:column])
        @record.update_attributes(params[:column] => params[:value])
      end
    end

    # override this method if you want to inject data in the record (or its associated objects) before the save
    def before_update_save(record); end

    # override this method if you want to do something after the save
    def after_update_save(record); end

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def update_authorized?
      authorized_for?(:action => :update)
    end
  end
end