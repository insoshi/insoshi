# wrap the action rendering for ActiveScaffold views
module ActionView #:nodoc:
  class Base
    # Adds two rendering options.
    #
    # ==render :super
    #
    # This syntax skips all template overrides and goes directly to the provided ActiveScaffold templates.
    # Useful if you want to wrap an existing template. Just call super!
    #
    # ==render :active_scaffold => #{controller.to_s}, options = {}+
    #
    # Lets you embed an ActiveScaffold by referencing the controller where it's configured.
    #
    # You may specify options[:constraints] for the embedded scaffold. These constraints have three effects:
    #   * the scaffold's only displays records matching the constraint
    #   * all new records created will be assigned the constrained values
    #   * constrained columns will be hidden (they're pretty boring at this point)
    #
    # You may also specify options[:conditions] for the embedded scaffold. These only do 1/3 of what
    # constraints do (they only limit search results). Any format accepted by ActiveRecord::Base.find is valid.
    #
    # Defining options[:label] lets you completely customize the list title for the embedded scaffold.
    #
    def render_with_active_scaffold(*args, &block)
      if args.first == :super
        options = args[1] || {}
        options[:locals] ||= {}
        options[:locals].reverse_merge! @local_assigns

        known_extensions = [:erb, :rhtml, :rjs, :haml]
        # search through call stack for a template file (normally matches on first caller)
        # note that we can't use split(':').first because windoze boxen may have an extra colon to specify the drive letter. the
        # solution is to count colons from the *right* of the string, not the left. see issue #299.
        template_path = caller.find{|c| known_extensions.include?(c.split(':')[-3].split('.').last.to_sym) }
        template = File.basename(template_path.split(':')[-3])
        template, format = template.split('.')

        # paths previous to current template_path must be ignored to avoid infinite loops when is called twice or more
        index = 0
        controller.class.active_scaffold_paths.each_with_index do |active_scaffold_template_path, i|
          index = i + 1 and break if template_path.include? active_scaffold_template_path
        end

        active_scaffold_template = controller.class.active_scaffold_paths.slice(index..-1).find_template(template, format, false)
        render(:file => active_scaffold_template, :locals => options[:locals])
      elsif args.first.is_a?(Hash) and args.first[:active_scaffold]
        require 'digest/md5'
        options = args.first

        remote_controller = options[:active_scaffold]
        constraints = options[:constraints]
        conditions = options[:conditions]
        eid = Digest::MD5.hexdigest(params[:controller] + remote_controller.to_s + constraints.to_s + conditions.to_s)
        session["as:#{eid}"] = {:constraints => constraints, :conditions => conditions, :list => {:label => args.first[:label]}}
        options[:params] ||= {}
        options[:params].merge! :eid => eid

        render_component :controller => remote_controller.to_s, :action => 'table', :params => options[:params]
      else
        render_without_active_scaffold(*args, &block)
      end
    end
    alias_method_chain :render, :active_scaffold
    
    def partial_pieces(partial_path)
      if partial_path.include?('/')
        return File.dirname(partial_path), File.basename(partial_path)
      else
        return controller.class.controller_path, partial_path
      end
    end
    
    # This is the template finder logic, keep it updated with however we find stuff in rails
    # currently this very similar to the logic in ActionBase::Base.render for options file
    # TODO: Work with rails core team to find a better way to check for this.
    def template_exists?(template_name, lookup_overrides = false)
      begin
        method = 'find_template'
        method << '_without_active_scaffold' unless lookup_overrides
        self.view_paths.send(method, template_name, @template_format)
        return true
      rescue ActionView::MissingTemplate => e
        return false
      end
    end
  end
end

module ActionView::Renderable
  def render_with_active_scaffold(view, local_assigns = {})
    old_local_assigns = view.instance_variable_get(:@local_assigns)
    view.instance_variable_set(:@local_assigns, local_assigns)
    output = render_without_active_scaffold(view, local_assigns)
    view.instance_variable_set(:@local_assigns, old_local_assigns)
    output
  end
  alias_method_chain :render, :active_scaffold
end
