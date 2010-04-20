module ActiveScaffold
  module TinyMceBridge
    module ViewHelpers
      def active_scaffold_includes(*args)
        tiny_mce_js = javascript_tag(%|
var action_link_close = ActiveScaffold.ActionLink.Abstract.prototype.close;
ActiveScaffold.ActionLink.Abstract.prototype.close = function() {
  this.adapter.select('textarea.mceEditor').each(function(elem) {
    tinyMCE.execCommand('mceRemoveControl', false, elem.id);
  });
  action_link_close.apply(this);
};
        |) if using_tiny_mce?
        super(*args) + (include_tiny_mce_if_needed || '') + (tiny_mce_js || '')
      end
    end

    module FormColumnHelpers
      def active_scaffold_input_text_editor(column, options)
        options[:class] = "#{options[:class]} mceEditor #{column.options[:class]}".strip
        html = []
        html << send(override_input(:textarea), column, options)
        html << javascript_tag("tinyMCE.execCommand('mceAddControl', false, '#{options[:id]}');") if request.xhr?
        html.join "\n"
      end

      def onsubmit
        submit_js = 'tinyMCE.triggerSave();this.select("textarea.mceEditor").each(function(elem) { tinyMCE.execCommand("mceRemoveControl", false, elem.id); });' if using_tiny_mce?
        [super, submit_js].compact.join ';'
      end
    end

    module SearchColumnHelpers
      def self.included(base)
        base.class_eval { alias_method :active_scaffold_search_text_editor, :active_scaffold_search_text }
      end
    end
  end
end

ActionView::Base.class_eval do
  include ActiveScaffold::TinyMceBridge::FormColumnHelpers
  include ActiveScaffold::TinyMceBridge::SearchColumnHelpers
  include ActiveScaffold::TinyMceBridge::ViewHelpers
end
