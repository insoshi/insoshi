module ActiveScaffold::Actions
  module Core
    def self.included(base)
      base.class_eval do
        after_filter :clear_flashes
      end
    end
    def render_field
      @record = if params[:in_place_editing]
        active_scaffold_config.model.find params[:id]
      else
        active_scaffold_config.model.new
      end
      @update_columns = []
      column = active_scaffold_config.columns[params[:column]]
      if params[:in_place_editing]
        render :inline => "<%= active_scaffold_input_for(active_scaffold_config.columns[params[:update_column].to_sym]) %>"
      elsif !column.nil?
        value = column_value_from_param_value(@record, column, params[:value])
        @record.send "#{column.name}=", value
        @update_columns << Array(params[:update_column]).collect {|column_name| active_scaffold_config.columns[column_name.to_sym]}
        @update_columns.flatten!
        after_render_field(@record, column)
      end
    end

    protected
    
    # override this method if you want to do something after render_field
    def after_render_field(record, column); end

    def authorized_for?(options = {})
      active_scaffold_config.model.authorized_for?(options)
    end

    def clear_flashes
      if request.xhr?
        flash.keys.each do |flash_key|
          flash[flash_key] = nil
        end
      end
    end

    def default_formats
      [:html, :js, :json, :xml, :yaml]
    end
    # Returns true if the client accepts one of the MIME types passed to it
    # ex: accepts? :html, :xml
    def accepts?(*types)
      for priority in request.accepts.compact
        if priority == Mime::ALL
          # Because IE always sends */* in the accepts header and we assume
          # that if you really wanted XML or something else you would say so
          # explicitly, we will assume */* to only ask for :html
          return types.include?(:html)
        elsif types.include?(priority.to_sym)
          return true
        end
      end
      false
    end

    def response_status
      if successful?
        action_name == 'create' ? 201 : 200
      else
        422
      end
    end

    # API response object that will be converted to XML/YAML/JSON using to_xxx
    def response_object
      @response_object = successful? ? (@record || @records) : @record.errors
    end

    # Success is the existence of certain variables and the absence of errors (when applicable).
    # Success can also be defined.
    def successful?
      if @successful.nil?
        @records or (@record and @record.errors.count == 0 and @record.no_errors_in_associated?)
      else
        @successful
      end
    end

    def successful=(val)
      @successful = (val) ? true : false
    end

    # Redirect to the main page (override if the ActiveScaffold is used as a component on another controllers page) for Javascript degradation
    def return_to_main
      redirect_to main_path_to_return
    end

    # Override this method on your controller to define conditions to be used when querying a recordset (e.g. for List). The return of this method should be any format compatible with the :conditions clause of ActiveRecord::Base's find.
    def conditions_for_collection
    end
  
    # Override this method on your controller to define joins to be used when querying a recordset (e.g. for List).  The return of this method should be any format compatible with the :joins clause of ActiveRecord::Base's find.
    def joins_for_collection
    end
  
    # Override this method on your controller to provide custom finder options to the find() call. The return of this method should be a hash.
    def custom_finder_options
      {}
    end
  
    #Overide this method on your controller to provide model with named scopes
    def beginning_of_chain
      active_scaffold_config.model
    end
        
    # Builds search conditions by search params for column names. This allows urls like "contacts/list?company_id=5".
    def conditions_from_params
      conditions = nil
      params.reject {|key, value| [:controller, :action, :id, :page, :sort, :sort_direction].include?(key.to_sym)}.each do |key, value|
        next unless active_scaffold_config.model.column_names.include?(key)
        if value.is_a?(Array)
          conditions = merge_conditions(conditions, ["#{active_scaffold_config.model.table_name}.#{key.to_s} in (?)", value])
        else
          conditions = merge_conditions(conditions, ["#{active_scaffold_config.model.table_name}.#{key.to_s} = ?", value])
        end
      end
      conditions
    end
    private
    def respond_to_action(action)
      respond_to do |type|
        send("#{action}_formats").each do |format|
          type.send(format){ send("#{action}_respond_to_#{format}") }
        end
      end
    end

    def response_code_for_rescue(exception)
      case exception
        when ActiveScaffold::RecordNotAllowed
          "403 Record Not Allowed"
        when ActiveScaffold::ActionNotAllowed
          "403 Action Not Allowed"
        else
          super
      end
    end
  end
end
