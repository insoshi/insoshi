# wrap find_template to search in ActiveScaffold paths when template is missing
module ActionView #:nodoc:
  class PathSet
    attr_accessor :active_scaffold_paths

    def find_template_with_active_scaffold(original_template_path, format = nil, html_fallback = true)
      begin
        find_template_without_active_scaffold(original_template_path, format, html_fallback)
      rescue MissingTemplate
        if active_scaffold_paths && original_template_path.include?('/')
          active_scaffold_paths.find_template_without_active_scaffold(original_template_path.split('/').last, format, html_fallback)
        else
          raise
        end
      end
    end
    alias_method_chain :find_template, :active_scaffold
  end
end

module ActionController #:nodoc:
  class Base
    def assign_names_with_active_scaffold
      assign_names_without_active_scaffold
      @template.view_paths.active_scaffold_paths = self.class.active_scaffold_paths if search_generic_view_paths?
    end
    alias_method_chain :assign_names, :active_scaffold

    def search_generic_view_paths?
      !self.is_a?(ActionMailer::Base) && self.class.action_methods.include?(self.action_name)
    end
  end
end
