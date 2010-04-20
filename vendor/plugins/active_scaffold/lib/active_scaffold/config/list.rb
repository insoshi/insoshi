module ActiveScaffold::Config
  class List < Base
    self.crud_type = :read

    def initialize(core_config)
      @core = core_config

      # inherit from global scope
      # full configuration path is: defaults => global table => local table
      @per_page = self.class.per_page
      @page_links_window = self.class.page_links_window
      
      # originates here
      @sorting = ActiveScaffold::DataStructures::Sorting.new(@core.columns)
      @sorting.set_default_sorting(@core.model)

      # inherit from global scope
      @empty_field_text = self.class.empty_field_text
      @pagination = self.class.pagination
      @show_search_reset = true
    end

    # global level configuration
    # --------------------------
    # how many records to show per page
    cattr_accessor :per_page
    @@per_page = 15

    # how many page links around current page to show
    cattr_accessor :page_links_window
    @@page_links_window = 2

    # what string to use when a field is empty
    cattr_accessor :empty_field_text
    @@empty_field_text = '-'

    # What kind of pagination to use:
    # * true: The usual pagination
    # * :infinite: Treat the source as having an infinite number of pages (i.e. don't count the records; useful for large tables where counting is slow and we don't really care anyway)
    # * false: Disable pagination
    cattr_accessor :pagination
    @@pagination = true

    # instance-level configuration
    # ----------------------------

    # provides access to the list of columns specifically meant for the Table to use
    def columns
      self.columns = @core.columns._inheritable unless @columns # lazy evaluation
      @columns
    end
    
    public :columns=

    # how many rows to show at once
    attr_accessor :per_page

    # how many page links around current page to show
    attr_accessor :page_links_window

    # What kind of pagination to use:
    # * true: The usual pagination
    # * :infinite: Treat the source as having an infinite number of pages (i.e. don't count the records; useful for large tables where counting is slow and we don't really care anyway)
    # * false: Disable pagination
    attr_accessor :pagination

    # what string to use when a field is empty
    attr_accessor :empty_field_text

    # show a link to reset the search next to filtered message
    attr_accessor :show_search_reset

    # the default sorting. should be an array of hashes of {column_name => direction}, e.g. [{:a => 'desc'}, {:b => 'asc'}]. to just sort on one column, you can simply provide a hash, though, e.g. {:a => 'desc'}.
    def sorting=(val)
      val = [val] if val.is_a? Hash
      sorting.clear
      val.each { |clause| sorting.add *Array(clause).first }
    end
    def sorting
      @sorting ||= ActiveScaffold::DataStructures::Sorting.new(@core.columns)
    end
    
    # overwrite the includes used for the count sql query
    attr_accessor :count_includes

    # the label for this List action. used for the header.
    attr_writer :label
    def label
      @label ? as_(@label, :count => 2) : @core.label(:count => 2)
    end

    attr_writer :no_entries_message
    def no_entries_message
      @no_entries_message ? @no_entries_message : :no_entries
    end

    attr_writer :filtered_message
    def filtered_message
      @filtered_message ? @filtered_message : :filtered
    end
    
    attr_writer :always_show_search
    def always_show_search
      @always_show_search && !search_partial.blank?
    end
    
    def search_partial
      return "search" if @core.actions.include?(:search)
      return "live_search" if @core.actions.include?(:live_search)
      return "field_search" if @core.actions.include?(:field_search)
    end
    
    # always show create
    attr_writer :always_show_create
    def always_show_create
      @always_show_create && @core.actions.include?(:create)
    end
    
    class UserSettings < UserSettings
      # This label has alread been localized.
      def label
        @session[:label] ? @session[:label] : @conf.label
      end

      def per_page
        @session['per_page'] = @params['limit'].to_i if @params.has_key? 'limit'
        @session['per_page'] || @conf.per_page
      end

      def page
        @session['page'] = @params['page'] if @params.has_key? 'page'
        @session['page'] || 1
      end

      def page=(value = nil)
        @session['page'] = value
      end

      def sorting
        # we want to store as little as possible in the session, but we want to return a Sorting data structure. so we recreate it each page load based on session data.
        @session['sort'] = [@params['sort'], @params['sort_direction']] if @params['sort'] and @params['sort_direction']
        @session['sort'] = nil if @params['sort_direction'] == 'reset'

        if @session['sort']
          sorting = @conf.sorting.clone
          sorting.set(*@session['sort'])
          return sorting
        else
          return @conf.sorting
        end
      end
      
      def count_includes
        @conf.count_includes
      end
    end
  end
end
