module ActiveScaffold::Actions
  module Show
    def self.included(base)
      base.before_filter :show_authorized?, :only => :show
    end

    def show
      do_show

      successful?
      respond_to do |type|
        type.html { render :action => 'show', :layout => true }
        type.js { render :partial => 'show', :layout => false }
        type.xml { render :xml => response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.json { render :text => response_object.to_json, :content_type => Mime::JSON, :status => response_status }
        type.yaml { render :text => response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end

    protected

    # A simple method to retrieve and prepare a record for showing.
    # May be overridden to customize show routine
    def do_show
      @record = find_if_allowed(params[:id], :read)
    end

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def show_authorized?
      authorized_for?(:action => :read)
    end
  end
end