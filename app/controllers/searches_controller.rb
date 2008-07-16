class SearchesController < ApplicationController
  include ApplicationHelper

  before_filter :login_required

  def index
    query = params[:q].strip
    model = strip_admin(params[:model])
    page  = params[:page] || 1
    if query.blank?
      @results = [].paginate
    else
      # We'll need to switch on the adapter name.
      adapter = ActiveRecord::Base.connection.adapter_name
      filters = {}
      if model == "Person" and not current_person.admin?
        # Filter out deactivated and email unverified users for non-admins.
        case adapter
        when "MySQL"
          filters['deactivated']    = 0
          filters['email_verified'] = 1 if global_prefs.email_verifications?
        when "PostgreSQL"
          raise "PostgreSQL search is not yet supported"
          query += " AND deactivated:f"
          query += " AND email_verified:t" if global_prefs.email_verifications?
        end
      elsif model == "Message"
        filters['recipient_id'] = current_person.id
        case adapter
        when "MySQL"
          filters['recipient_deleted_at'] = 0  # 0 is the same as NULL (!)
        when "PostgreSQL"
          raise "PostgreSQL search is not yet supported"
        end
      end
      @search = Ultrasphinx::Search.new(:query => query, 
                                        :filters => filters,
                                        :page => page,
                                        :class_names => model)
      @search.run
      @results = @search.results
    end
  end
  
  private
    
    # Strip off "Admin::" from the model name.
    # This is needed for, e.g., searches in the admin view
    def strip_admin(model)
      model.split("::").last
    end
end
