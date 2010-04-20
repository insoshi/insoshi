class ActionController::Base
  class_inheritable_accessor :generic_view_paths
  self.generic_view_paths = []

  # Returns the view path that contains the given relative template path.
  def find_generic_base_path_for(template_path, extension)
    self.generic_view_paths.each do |generic_path|
      template_file_name = File.basename("#{template_path}.#{extension}")
      generic_file_path = File.join(generic_path, template_file_name)
      return generic_file_path if File.file?(generic_file_path)
    end
    nil
  end
end

class ActionView::Base
  def template_exists?(template)
    begin
      return _pick_template(template)
    rescue ActionView::MissingTemplate
      return nil
    end
  end

  private
  def _pick_template_with_generic(template_path)
    begin
      _pick_template_without_generic(template_path)
    rescue ActionView::MissingTemplate
      path = template_path.sub(/^\//, '')
      if m = path.match(/(.*)\.(\w+)$/)
        template_file_name, template_file_extension = m[1], m[2]
      else
        template_file_name = path
      end
      if m = template_file_name.match(/\/(\w+)$/)
        generic_template = m[1]
      end
      if search_generic_view_paths? && generic_template && (template = self.view_paths[generic_template])
        template
      else
        raise
      end
    end
  end
  alias_method_chain :_pick_template, :generic

  def search_generic_view_paths?
    !controller.is_a?(ActionMailer::Base) && controller.class.action_methods.include?(controller.action_name)
  end
end
