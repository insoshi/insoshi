module ActiveScaffold
  module Helpers
    # All extra helpers that should be included in the View.
    # Also a dumping ground for uncategorized helpers.
    module ViewHelpers
      include ActiveScaffold::Helpers::IdHelpers
      include ActiveScaffold::Helpers::AssociationHelpers
      include ActiveScaffold::Helpers::PaginationHelpers
      include ActiveScaffold::Helpers::ListColumnHelpers
      include ActiveScaffold::Helpers::ShowColumnHelpers
      include ActiveScaffold::Helpers::FormColumnHelpers
      include ActiveScaffold::Helpers::SearchColumnHelpers
      include ActiveScaffold::Helpers::CountryHelpers

      ##
      ## Delegates
      ##

      # access to the configuration variable
      def active_scaffold_config
        @controller.class.active_scaffold_config
      end

      def active_scaffold_config_for(*args)
        @controller.class.active_scaffold_config_for(*args)
      end

      def active_scaffold_controller_for(*args)
        @controller.class.active_scaffold_controller_for(*args)
      end

      ##
      ## Uncategorized
      ##

      def generate_temporary_id
        (Time.now.to_f*1000).to_i.to_s
      end

      # Turns [[label, value]] into <option> tags
      # Takes optional parameter of :include_blank
      def option_tags_for(select_options, options = {})
        select_options.insert(0,[as_(:_select_),nil]) if options[:include_blank]
        select_options.collect do |option|
          label, value = option[0], option[1]
          value.nil? ? "<option value="">#{label}</option>" : "<option value=\"#{value}\">#{label}</option>"
        end
      end

      # Should this column be displayed in the subform?
      def in_subform?(column, parent_record)
        return true unless column.association

        # Polymorphic associations can't appear because they *might* be the reverse association, and because you generally don't assign an association from the polymorphic side ... I think.
        return false if column.polymorphic_association?

        # A column shouldn't be in the subform if it's the reverse association to the parent
        return false if column.association.reverse_for?(parent_record.class)

        return true
      end

      def form_remote_upload_tag(url_for_options = {}, options = {})
        onsubmits = options[:onsubmit] ? [ options[:onsubmit] ] : [ ]
        # simulate a "loading". the setTimeout prevents the Form.disable from being called before the submit, so that data actually posts.
        onsubmits << "setTimeout(function() { #{options[:loading]} }, 10); "
        onsubmits << "return true" # make sure the form still submits

        options[:onsubmit] = onsubmits * ';'
        options[:target] = action_iframe_id(url_for_options)
        options[:multipart] = true

        output=""
        output << form_tag(url_for_options, options)
        output << "<iframe id='#{action_iframe_id(url_for_options)}' name='#{action_iframe_id(url_for_options)}' style='display:none'></iframe>"
      end

      # Provides list of javascripts to include with +javascript_include_tag+
      # You can use this with your javascripts like
      #   <%= javascript_include_tag :defaults, 'your_own_cool_script', active_scaffold_javascripts, :cache => true %>
      def active_scaffold_javascripts(frontend = :default)
        ActiveScaffold::Config::Core.javascripts(frontend).collect do |name|
          ActiveScaffold::Config::Core.asset_path(name, frontend)
        end
      end
      
      # Provides stylesheets to include with +stylesheet_link_tag+
      def active_scaffold_stylesheets(frontend = :default)
        [ActiveScaffold::Config::Core.asset_path("stylesheet.css", frontend)]
      end

      # Provides stylesheets for IE to include with +stylesheet_link_tag+ 
      def active_scaffold_ie_stylesheets(frontend = :default)
        [ActiveScaffold::Config::Core.asset_path("stylesheet-ie.css", frontend)]
      end

      # easy way to include ActiveScaffold assets
      def active_scaffold_includes(*args)
        frontend = args.first.is_a?(Symbol) ? args.shift : :default
        options = args.first.is_a?(Hash) ? args.shift : {}
        js = javascript_include_tag(*active_scaffold_javascripts(frontend).push(options))

        css = stylesheet_link_tag(*active_scaffold_stylesheets(frontend).push(options))
        options[:cache] += '_ie' if options[:cache].is_a? String
        options[:concat] += '_ie' if options[:concat].is_a? String
        ie_css = stylesheet_link_tag(*active_scaffold_ie_stylesheets(frontend).push(options))

        js + "\n" + css + "\n<!--[if IE]>" + ie_css + "<![endif]-->\n"
      end

      # a general-use loading indicator (the "stuff is happening, please wait" feedback)
      def loading_indicator_tag(options)
        image_tag "/images/active_scaffold/default/indicator.gif", :style => "visibility:hidden;", :id => loading_indicator_id(options), :alt => "loading indicator", :class => "loading-indicator"
      end

      # Creates a javascript-based link that toggles the visibility of some element on the page.
      # By default, it toggles the visibility of the sibling after the one it's nested in. You may pass custom javascript logic in options[:of] to change that, though. For example, you could say :of => '$("my_div_id")'.
      # You may also flag whether the other element is visible by default or not, and the initial text will adjust accordingly.
      def link_to_visibility_toggle(options = {})
        options[:of] ||= '$(this.parentNode).next()'
        options[:default_visible] = true if options[:default_visible].nil?

        link_text = options[:default_visible] ? as_(:hide) : as_(:show)
        link_to_function link_text, "e = #{options[:of]}; e.toggle(); this.innerHTML = (e.style.display == 'none') ? '#{as_(:show)}' : '#{as_(:hide)}'", :class => 'visibility-toggle'
      end

      def skip_action_link(link)
        (link.security_method_set? or controller.respond_to? link.security_method) and !controller.send(link.security_method)
      end

      def render_action_link(link, url_options, record = nil, html_options = {})
        url_options = url_options.clone
        url_options[:action] = link.action
        url_options[:controller] = link.controller if link.controller
        url_options.delete(:search) if link.controller and link.controller.to_s != params[:controller]
        url_options.merge! link.parameters if link.parameters

        html_options.reverse_merge! link.html_options.merge(:class => link.action)
        if link.inline?
          # NOTE this is in url_options instead of html_options on purpose. the reason is that the client-side
          # action link javascript needs to submit the proper method, but the normal html_options[:method]
          # argument leaves no way to extract the proper method from the rendered tag.
          url_options[:_method] = link.method

          if link.method != :get and respond_to?(:protect_against_forgery?) and protect_against_forgery?
            url_options[:authenticity_token] = form_authenticity_token
          end

          # robd: protect against submitting get links as forms, since this causes annoying 
          # 'Do you wish to resubmit your form?' messages whenever you go back and forwards.
        elsif link.method != :get
          # Needs to be in html_options to as the adding _method to the url is no longer supported by Rails
          html_options[:method] = link.method
        end

        html_options[:confirm] = link.confirm(record.try(:to_label)) if link.confirm?
        html_options[:position] = link.position if link.position and link.inline?
        html_options[:class] += ' action' if link.inline?
        html_options[:popup] = true if link.popup?
        html_options[:id] = action_link_id("#{id_from_controller(url_options[:controller]) + '-' if url_options[:parent_controller]}" + "#{url_options[:associations].to_s + '-' if url_options[:associations]}" + url_options[:action].to_s,url_options[:id] || url_options[:parent_id])

        if link.dhtml_confirm?
          html_options[:class] += ' action' if !link.inline?
          html_options[:page_link] = 'true' if !link.inline?
          html_options[:dhtml_confirm] = link.dhtml_confirm.value
          html_options[:onclick] = link.dhtml_confirm.onclick_function(controller,action_link_id(url_options[:action],url_options[:id] || url_options[:parent_id]))
        end
        html_options[:class] += " #{link.html_options[:class]}" unless link.html_options[:class].blank?

        # issue 260, use url_options[:link] if it exists. This prevents DB data from being localized.
        label = url_options.delete(:link) || link.label
        link_to label, url_options, html_options
      end

      def column_class(column, column_value)
        classes = []
        classes << "#{column.name}-column"
        classes << column.css_class unless column.css_class.nil?
        classes << 'empty' if column_empty? column_value
        classes << 'sorted' if active_scaffold_config.list.user.sorting.sorts_on?(column)
        classes << 'numeric' if column.column and [:decimal, :float, :integer].include?(column.column.type)
        classes.join(' ')
      end

      def column_empty?(column_value)
        empty = column_value.nil?
        empty ||= column_value.empty? if column_value.respond_to? :empty?
        empty ||= ['&nbsp;', active_scaffold_config.list.empty_field_text].include? column_value if String === column_value
        return empty
      end

      def column_calculation(column)
        conditions = controller.send(:all_conditions)
        includes = active_scaffold_config.list.count_includes
        includes ||= controller.send(:active_scaffold_includes) unless conditions.nil?
        calculation = active_scaffold_config.model.calculate(column.calculate, column.name, :conditions => conditions,
         :joins => controller.send(:joins_for_collection), :include => includes)
      end

      def render_column_calculation(column)
        calculation = column_calculation(column)
        override_formatter = "render_#{column.name}_#{column.calculate}"
        calculation = send(override_formatter, calculation) if respond_to? override_formatter

        "#{as_(column.calculate)}: #{format_column_value nil, column, calculation}"
      end

      def column_show_add_existing(column)
        (column.allow_add_existing and options_for_association_count(column.association) > 0)
      end

      def column_show_add_new(column, associated, record)
        value = column.plural_association? or (column.singular_association? and not associated.empty?)
        value = false unless record.class.authorized_for?(:crud_type => :create)
        value
      end
    end
  end
end
