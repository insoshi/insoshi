module ActiveScaffold::Actions
  module Search
    include ActiveScaffold::Actions::CommonSearch
    def self.included(base)
      base.before_filter :search_authorized_filter, :only => :show_search
      base.before_filter :store_search_params_into_session, :only => [:list, :index]
      base.before_filter :do_search, :only => [:list, :index]
      base.helper_method :search_params
    end

    def show_search
      respond_to_action(:search)
    end

    protected
    def search_respond_to_html
      render(:action => "search")
    end
    def search_respond_to_js
      render(:partial => "search")
    end
    def do_search
      query = search_params.to_s.strip rescue ''

      unless query.empty?
        columns = active_scaffold_config.search.columns
        text_search = active_scaffold_config.search.text_search
        search_conditions = self.class.create_conditions_for_columns(query.split(' '), columns, text_search)
        self.active_scaffold_conditions = merge_conditions(self.active_scaffold_conditions, search_conditions)
        @filtered = !search_conditions.blank?

        includes_for_search_columns = columns.collect{ |column| column.includes}.flatten.uniq.compact
        self.active_scaffold_includes.concat includes_for_search_columns

        active_scaffold_config.list.user.page = nil
      end
    end

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def search_authorized?
      authorized_for?(:crud_type => :read)
    end
    private
    def search_authorized_filter
      link = active_scaffold_config.search.link || active_scaffold_config.search.class.link
      raise ActiveScaffold::ActionNotAllowed unless self.send(link.security_method)
    end
    def search_formats
      (default_formats + active_scaffold_config.formats + active_scaffold_config.search.formats).uniq
    end
  end
end
