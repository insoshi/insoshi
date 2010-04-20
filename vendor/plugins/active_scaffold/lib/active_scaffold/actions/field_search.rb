module ActiveScaffold::Actions
  module FieldSearch
    include ActiveScaffold::Actions::CommonSearch
    def self.included(base)
      base.before_filter :search_authorized_filter, :only => :show_search
      base.before_filter :store_search_params_into_session, :only => [:list, :index]
      base.before_filter :do_search, :only => [:list, :index]
      base.helper_method :field_search_params
    end

    # FieldSearch uses params[:search] and not @record because search conditions do not always pass the Model's validations.
    # This facilitates for example, textual searches against associations via .search_sql
    def show_search
      @record = active_scaffold_config.model.new
      respond_to_action(:field_search)
    end

    protected
    def field_search_params
      search_params || {}
    end

    def field_search_respond_to_html
      render(:action => "field_search")
    end
    
    def field_search_respond_to_js
      render(:partial => "field_search")
    end

    def do_search
      unless search_params.nil?
        text_search = active_scaffold_config.field_search.text_search
        search_conditions = []
        columns = active_scaffold_config.field_search.columns
        search_params.each do |key, value|
          next unless columns.include? key
          search_conditions << self.class.condition_for_column(active_scaffold_config.columns[key], value, text_search)
        end
        search_conditions.compact!
        self.active_scaffold_conditions = merge_conditions(self.active_scaffold_conditions, *search_conditions)
        @filtered = !search_conditions.blank?

        includes_for_search_columns = columns.collect{ |column| column.includes}.flatten.uniq.compact
        self.active_scaffold_includes.concat includes_for_search_columns

        active_scaffold_config.list.user.page = nil
      end
    end

    private
    def search_authorized_filter
      link = active_scaffold_config.field_search.link || active_scaffold_config.field_search.class.link
      raise ActiveScaffold::ActionNotAllowed unless self.send(link.security_method)
    end
    def field_search_formats
      (default_formats + active_scaffold_config.formats + active_scaffold_config.field_search.formats).uniq
    end
  end
end
