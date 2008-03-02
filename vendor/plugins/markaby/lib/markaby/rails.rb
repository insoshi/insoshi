module ActionView # :nodoc:
  class Base # :nodoc:
    def render_template(template_extension, template, file_path = nil, local_assigns = {})
      if handler = @@template_handlers[template_extension]
        template ||= read_template_file(file_path, template_extension)
        handler.new(self).render(template, local_assigns, file_path)
      else
        compile_and_render_template(@@template_handlers[template_extension.to_sym], template, file_path, local_assigns)
      end
    end
  end
end

module Markaby
  module Rails
    # Markaby helpers for Rails.
    module ActionControllerHelpers
      # Returns a string of HTML built from the attached +block+.  Any +options+ are
      # passed into the render method.
      #
      # Use this method in your controllers to output Markaby directly from inside.
      def render_markaby(options = {}, &block)
        render options.merge({ :text => Builder.new(options[:locals], self, &block).to_s })
      end
    end

    class ActionViewTemplateHandler # :nodoc:
      def initialize(action_view)
        @action_view = action_view
      end
      def render(template, local_assigns, file_path)
        template = Template.new(template)
        template.path = file_path
        template.render(@action_view.assigns.merge(local_assigns), @action_view)
      end
    end
      
    class Builder < Markaby::Builder # :nodoc:
      def initialize(*args, &block)
        super *args, &block
        
        @assigns.each { |k, v| @helpers.instance_variable_set("@#{k}", v) }
      end
      
      def flash(*args)
        @helpers.controller.send(:flash, *args)
      end
    
      # Emulate ERB to satisfy helpers like <tt>form_for</tt>.
      def _erbout
        @_erbout ||= FauxErbout.new(self)
      end

      # Content_for will store the given block in an instance variable for later use 
      # in another template or in the layout.
      #
      # The name of the instance variable is content_for_<name> to stay consistent 
      # with @content_for_layout which is used by ActionView's layouts.
      #
      # Example:
      #
      #   content_for("header") do
      #     h1 "Half Shark and Half Lion"
      #   end
      #
      # If used several times, the variable will contain all the parts concatenated.
      def content_for(name, &block)
        @helpers.assigns["content_for_#{name}"] =
          eval("@content_for_#{name} = (@content_for_#{name} || '') + capture(&block)")
      end
    end


    
    Template.builder_class = Builder
    
    class FauxErbout < ::Builder::BlankSlate # :nodoc:
      def initialize(builder)
        @builder = builder
      end
      def nil? # see ActionView::Helpers::CaptureHelper#capture
        true
      end
      def method_missing(*args, &block)
        @builder.send *args, &block
      end
    end

  end
end
