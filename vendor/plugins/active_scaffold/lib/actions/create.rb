module ActiveScaffold::Actions
  module Create
    def self.included(base)
      base.before_filter :create_authorized?, :only => [:new, :create]
      base.verify :method => :post,
                  :only => :create,
                  :redirect_to => { :action => :index }
    end

    def new
      do_new

      respond_to do |type|
        type.html do
          if successful?
            render(:action => 'create_form', :layout => true)
          else
            return_to_main
          end
        end
        type.js do
          render(:partial => 'create_form', :layout => false)
        end
      end
    end

    def create
      do_create
      @insert_row = params[:parent_controller].nil?

      respond_to do |type|
        type.html do
          if params[:iframe]=='true' # was this an iframe post ?
            responds_to_parent do
              if successful?
                render :action => 'create.rjs', :layout => false
              else
                render :action => 'form_messages.rjs', :layout => false
              end
            end
          else
            if successful?
              flash[:info] = as_('Created %s', @record.to_label)
              if active_scaffold_config.create.edit_after_create
                redirect_to params.merge(:action => "edit", :id => @record.id)
              else
                return_to_main
              end
            else
              render(:action => 'create_form', :layout => true)
            end
          end
        end
        type.js do
          render :action => 'create.rjs', :layout => false
        end
        type.xml { render :xml => response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.json { render :text => response_object.to_json, :content_type => Mime::JSON, :status => response_status }
        type.yaml { render :text => response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end

    protected

    # A simple method to find and prepare an example new record for the form
    # May be overridden to customize the behavior (add default values, for instance)
    def do_new
      @record = active_scaffold_config.model.new
      apply_constraints_to_record(@record)
      @record
    end

    # A somewhat complex method to actually create a new record. The complexity is from support for subforms and associated records.
    # If you want to customize this behavior, consider using the +before_create_save+ and +after_create_save+ callbacks.
    def do_create
      begin
        active_scaffold_config.model.transaction do
          @record = update_record_from_params(active_scaffold_config.model.new, active_scaffold_config.create.columns, params[:record])
          apply_constraints_to_record(@record, :allow_autosave => true)
          before_create_save(@record)
          self.successful = [@record.valid?, @record.associated_valid?].all? {|v| v == true} # this syntax avoids a short-circuit
          if successful?
            @record.save! and @record.save_associated!
            after_create_save(@record)
          end
        end
      rescue ActiveRecord::RecordInvalid
      end
    end

    # override this method if you want to inject data in the record (or its associated objects) before the save
    def before_create_save(record); end

    # override this method if you want to do something after the save
    def after_create_save(record); end

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def create_authorized?
      authorized_for?(:action => :create)
    end
  end
end
