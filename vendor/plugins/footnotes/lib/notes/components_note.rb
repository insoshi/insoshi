require "#{File.dirname(__FILE__)}/abstract_note"
require "#{File.dirname(__FILE__)}/controller_note"
require "#{File.dirname(__FILE__)}/view_note"
require "#{File.dirname(__FILE__)}/params_note"

module Footnotes
  module Notes
    module ComponentsNote
      def self.new(controller = nil); end

      def initialize(controller)
        super
        @controller = controller
      end

      def row
        "#{@controller.controller_name.camelize}##{@controller.action_name.camelize} Component"
      end

      def to_sym
        @spicy_sym ||= "#{@controller.controller_name}_#{@controller.action_name}_#{self.class.to_sym}_#{(rand*1000).to_i}_component"
      end
      
      def legend
        "#{super} for #{row}"
      end
    end

    class ControllerComponentNote < ControllerNote; include ComponentsNote; end
    class ViewComponentNote < ViewNote; include ComponentsNote; end
    class ParamsComponentNote < ParamsNote; include ComponentsNote; end
  end

  module Components
    def self.included(base)
      base.class_eval do
        alias_method_chain :add_footnotes!, :component
        @@component_notes = [ :controller, :view, :params ]
      end
    end

    def add_footnotes_with_component!
      if component_request?
        initialize_component_notes!
        Footnotes::Filter.notes.unshift(*@notes)
        close!
      else
        add_footnotes_without_component!
        Footnotes::Filter.notes.delete_if {|note| note.class.to_s =~ /(ComponentNote)$/}
      end
    end

    protected
    def initialize_component_notes!
      @@component_notes.flatten.each do |note|
        begin
          note = eval("Footnotes::Notes::#{note.to_s.camelize}ComponentNote").new(@controller) if note.is_a?(Symbol) || note.is_a?(String)
          @notes << note if note.respond_to?(:valid?) && note.valid?
        rescue Exception => e
          # Discard note if it has a problem
          log_error("Footnotes #{note.to_s.camelize}ComponentNote Exception", e)
          next
        end
      end
    end
  end
end

Footnotes::Filter.send :include, Footnotes::Components if Footnotes::Filter.notes.include?(:components)