module ActiveScaffold::Actions
  module Search
    def self.included(base)
      base.before_filter :search_authorized?, :only => :show_search
      base.before_filter :do_search
    end

    def show_search
      respond_to do |type|
        type.html { render(:action => "search") }
        type.js { render(:partial => "search", :layout => false) }
      end
    end

    protected

    def do_search
      @query = params[:search].to_s.strip rescue ''

      unless @query.empty?
        columns = active_scaffold_config.search.columns
        like_pattern = active_scaffold_config.search.full_text_search? ? '%?%' : '?%'
        self.active_scaffold_conditions = merge_conditions(self.active_scaffold_conditions, ActiveScaffold::Finder.create_conditions_for_columns(@query.split(' '), columns, like_pattern))

        includes_for_search_columns = columns.collect{ |column| column.includes}.flatten.uniq.compact
        self.active_scaffold_joins.concat includes_for_search_columns

        active_scaffold_config.list.user.page = nil
      end
    end

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def search_authorized?
      authorized_for?(:action => :read)
    end
  end
end
