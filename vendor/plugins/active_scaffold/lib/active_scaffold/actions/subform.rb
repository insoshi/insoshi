module ActiveScaffold::Actions
  module Subform
    def edit_associated
      @parent_record = params[:id].nil? ? active_scaffold_config.model.new : find_if_allowed(params[:id], :update)
      @column = active_scaffold_config.columns[params[:association]]

      # NOTE: we don't check whether the user is allowed to update this record, because if not, we'll still let them associate the record. we'll just refuse to do more than associate, is all.
      @record = @column.association.klass.find(params[:associated_id]) if params[:associated_id]
      @record ||= @column.association.klass.new

      @scope = "[#{@column.name}]"
      @scope += (@record.new_record?) ? "[#{(Time.now.to_f*1000).to_i.to_s}]" : "[#{@record.id}]" if @column.plural_association?

      render :action => 'edit_associated.rjs', :layout => false
    end
  end
end