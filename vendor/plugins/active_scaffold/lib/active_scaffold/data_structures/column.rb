module ActiveScaffold::DataStructures
  class Column
    include ActiveScaffold::Configurable

    attr_reader :active_record_class

    # this is the name of the getter on the ActiveRecord model. it is the only absolutely required attribute ... all others will be inferred from this name.
    attr_accessor :name

    # Whether to enable inplace editing for this column. Currently works for text columns, in the List.
    attr_reader :inplace_edit
    def inplace_edit=(value)
      self.clear_link if value
      @inplace_edit = value
    end

    # Whether this column set is collapsed by default in contexts where collapsing is supported
    attr_accessor :collapsed

    # Whether to enable add_existing for this column
    attr_accessor :allow_add_existing
    
    # Any extra parameters this particular column uses.  This is for create/update purposes.
    def params
      # lazy initialize
      @params ||= Set.new
    end

    # the display-name of the column. this will be used, for instance, as the column title in the table and as the field name in the form.
    # if left alone it will utilize human_attribute_name which includes localization
    attr_writer :label
    def label
      as_(@label) || active_record_class.human_attribute_name(name.to_s)
    end

    # a textual description of the column and its contents. this will be displayed with any associated form input widget, so you may want to consider adding a content example.
    attr_writer :description
    def description
      if @description
        @description
      else
        I18n.t name, :scope => [:activerecord, :description, active_record_class.to_s.underscore.to_sym], :default => ''
      end
    end

    # this will be /joined/ to the :name for the td's class attribute. useful if you want to style columns on different ActiveScaffolds the same way, but the columns have different names.
    attr_accessor :css_class

    # whether the field is required or not. used on the form for visually indicating the fact to the user.
    # TODO: move into predicate
    attr_writer :required
    def required?
      @required
    end

    # sorting on a column can be configured four ways:
    #   sort = true               default, uses intelligent sorting sql default
    #   sort = false              sometimes sorting doesn't make sense
    #   sort = {:sql => ""}       define your own sql for sorting. this should be result in a sortable value in SQL. ActiveScaffold will handle the ascending/descending.
    #   sort = {:method => ""}    define ruby-side code for sorting. this is SLOW with large recordsets!
    def sort=(value)
      if value.is_a? Hash
        value.assert_valid_keys(:sql, :method)
        @sort = value
      else
        @sort = value ? true : false # force true or false
      end
    end

    def sort
      self.initialize_sort if @sort === true
      @sort
    end

    def sortable?
      sort != false && !sort.nil?
    end

    # a configuration helper for the self.sort property. simply provides a method syntax instead of setter syntax.
    def sort_by(options)
      self.sort = options
    end

    # supported options:
    #   * for association columns
    #     * :select - displays a simple <select> or a collection of checkboxes to (dis)associate records
    attr_writer :form_ui
    def form_ui
      @form_ui
    end

    attr_writer :list_ui
    def list_ui
      @list_ui || @form_ui
    end

    attr_writer :search_ui
    def search_ui
      @search_ui || @form_ui || (@association && !polymorphic_association? ? :select : nil)
    end

    # a place to store dev's column specific options
    attr_accessor :options
    def options
      @options ||= {}
    end

    # associate an action_link with this column
    attr_reader :link

    # set an action_link to nested list or inline form in this column
    def autolink?
      @autolink and self.association.reverse
    end

    # this should not only delete any existing link but also prevent column links from being automatically added by later routines
    def clear_link
      @link = nil
      @autolink = false
    end

    def set_link(action, options = {})
      if action.is_a? ActiveScaffold::DataStructures::ActionLink
        @link = action
      else
        options[:label] ||= self.label
        options[:position] ||= :after unless options.has_key?(:position)
        options[:type] ||= :member
        @link = ActiveScaffold::DataStructures::ActionLink.new(action, options)
      end
    end

    # define a calculation for the column. anything that ActiveRecord::Calculations::ClassMethods#calculate accepts will do.
    attr_accessor :calculate

    # get whether to run a calculation on this column
    def calculation?
      !(@calculate == false or @calculate.nil?)
    end

    # a collection of associations to pre-load when finding the records on a page
    attr_reader :includes
    def includes=(value)
      @includes = value.is_a?(Array) ? value : [value] # automatically convert to an array
    end

    # a collection of columns to load when eager loading is disabled, if it's nil all columns will be loaded
    attr_accessor :select_columns

    # describes how to search on a column
    #   search = true           default, uses intelligent search sql
    #   search = "CONCAT(a, b)" define your own sql for searching. this should be the "left-side" of a WHERE condition. the operator and value will be supplied by ActiveScaffold.
    attr_writer :search_sql
    def search_sql
      self.initialize_search_sql if @search_sql === true
      @search_sql
    end
    def searchable?
      search_sql != false && search_sql != nil
    end

    # to modify the default order of columns
    attr_accessor :weight

    # to set how many associated records a column with plural association must show in list
    cattr_accessor :associated_limit
    @@associated_limit = 3
    attr_accessor :associated_limit

    # whether the number of associated records must be shown or not
    cattr_accessor :associated_number
    @@associated_number = true
    attr_writer :associated_number
    def associated_number?
      @associated_number
    end

    # whether a blank row must be shown in the subform
    cattr_accessor :show_blank_record
    @@show_blank_record = true
    attr_writer :show_blank_record
    def show_blank_record?(associated)
      if @show_blank_record
        return false unless self.association.klass.authorized_for?(:crud_type => :create)
        self.plural_association? or (self.singular_association? and associated.empty?)
      end
    end

    # methods for automatic links in singular association columns
    cattr_accessor :actions_for_association_links
    @@actions_for_association_links = [:new, :edit, :show]
    attr_accessor :actions_for_association_links

    # ----------------------------------------------------------------- #
    # the below functionality is intended for internal consumption only #
    # ----------------------------------------------------------------- #

    # the ConnectionAdapter::*Column object from the ActiveRecord class
    attr_reader :column

    # the association from the ActiveRecord class
    attr_reader :association
    def singular_association?
      self.association and [:has_one, :belongs_to].include? self.association.macro
    end
    def plural_association?
      self.association and [:has_many, :has_and_belongs_to_many].include? self.association.macro
    end
    def through_association?
      self.association and self.association.options[:through]
    end
    def polymorphic_association?
      self.association and self.association.options.has_key? :polymorphic and self.association.options[:polymorphic]
    end

    # an interpreted property. the column is virtual if it isn't from the active record model or any associated models
    def virtual?
      column.nil? && association.nil?
    end

    # this is so that array.delete and array.include?, etc., will work by column name
    def ==(other) #:nodoc:
      # another column
      if other.respond_to? :name and other.class == self.class
        self.name == other.name.to_sym
      # a string or symbol
      elsif other.respond_to? :to_sym
        self.name == other.to_sym rescue false # catch "interning empty string"
      # unknown
      else
        self.eql? other
      end
    end

    # instantiation is handled internally through the DataStructures::Columns object
    def initialize(name, active_record_class) #:nodoc:
      self.name = name.to_sym
      @column = active_record_class.columns_hash[self.name.to_s]
      @association = active_record_class.reflect_on_association(self.name)
      @autolink = !@association.nil?
      @active_record_class = active_record_class
      @table = active_record_class.table_name
      @weight = 0
      @associated_limit = self.class.associated_limit
      @associated_number = self.class.associated_number
      @show_blank_record = self.class.show_blank_record
      @actions_for_association_links = self.class.actions_for_association_links.clone if @association
      @options = {:format => :i18n_number} if @column.try(:number?)
      @form_ui = :checkbox if @column and @column.type == :boolean
      @allow_add_existing = true

      # default all the configurable variables
      self.css_class = ''
      self.required = false
      self.sort = true
      self.search_sql = true

      self.includes = (association and not polymorphic_association?) ? [association.name] : []
    end

    # just the field (not table.field)
    def field_name
      return nil if virtual?
      column ? @active_record_class.connection.quote_column_name(column.name) : association.primary_key_name
    end

    def <=>(other_column)
      order_weight = self.weight <=> other_column.weight
      order_weight != 0 ? order_weight : self.name.to_s <=> other_column.name.to_s
    end

    protected

    def initialize_sort
      if self.virtual?
        # we don't automatically enable method sorting for virtual columns because it's slow, and we expect fewer complaints this way.
        self.sort = false
      else
        if self.singular_association?
          self.sort = {:method => "#{self.name}.to_s"}
        elsif self.plural_association?
          self.sort = {:method => "#{self.name}.join(',')"}
        else
          self.sort = {:sql => self.field}
        end
      end
    end

    def initialize_search_sql
      self.search_sql = unless self.virtual?
        if association.nil?
          self.field.to_s
        elsif !self.polymorphic_association?
          [association.klass.table_name, association.klass.primary_key].collect! do |str|
            association.klass.connection.quote_column_name str
          end.join('.')
        end
      end
    end

    # the table name from the ActiveRecord class
    attr_reader :table

    # the table.field name for this column, if applicable
    def field
      @field ||= [@active_record_class.connection.quote_column_name(@table), field_name].join('.')
    end
  end
end
