module ActiveScaffold::Actions
  module Delete
    def self.included(base)
      base.before_filter :delete_authorized?, :only => [:delete, :destroy]
    end

    # this method is for html mode. it provides "the missing action" (http://thelucid.com/articles/2006/07/26/simply-restful-the-missing-action).
    # it also gives us delete confirmation for html mode. woo!
    def delete
      @record = find_if_allowed(params[:id], :destroy)
      render :action => 'delete'
    end

    def destroy
      return redirect_to(params.merge(:action => :delete)) if request.get?

      do_destroy

      respond_to do |type|
        type.html do
          flash[:info] = as_('Deleted %s', @record.to_label)
          return_to_main
        end
        type.js { render(:action => 'destroy.rjs', :layout => false) }
        type.xml { render :xml => successful? ? "" : response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.json { render :text => successful? ? "" : response_object.to_json, :content_type => Mime::JSON, :status => response_status }
        type.yaml { render :text => successful? ? "" : response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end

    protected

    # A simple method to handle the actual destroying of a record
    # May be overridden to customize the behavior
    def do_destroy
      @record = find_if_allowed(params[:id], :destroy)
      self.successful = @record.destroy
    end

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def delete_authorized?
      authorized_for?(:action => :destroy)
    end
  end
end