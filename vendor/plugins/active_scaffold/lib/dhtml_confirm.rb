# Matt Mower <matt@cominded.com>
# 
# A base class for creating DHTML confirmation types.
#
# The real work is done by the onclick_function and onclick_handler methods. In
# general it should only be required to override the default onclick_handler
# method and provide the specific Javascript required to invoke the DHTML confirm
# dialog of your choice.
#
# It is up to this dialog, if the user confirms the intended action, to invoke
# the function window.gFireModalLink() to trigger the intended action of the link.
# For example, using the Modalbox library, you would use something like:
#
#     Modalbox.hide( {
#               afterHide: function() {
#                 window.gFireModalLink();
#               } } );
#
# By default the only action recognized is :value which is used to add a
# dhtml_confirm attribute to the link <a> tag. This value is detected by the
# ActiveScaffold link and triggers the DHTML confirmation logic.
#
class DHTMLConfirm
  attr_accessor :value, :message, :options
  
  def initialize( options = {} )
    @options = options
    @value = @options.delete(:value) { |key| "yes" }
    @message = @options.delete(:message) { |key| "Are you sure?" }
  end
  
  def onclick_function( controller, link_id )
    script = <<-END
window.gFireModalLink = function() {
  var link = $('#{link_id}').action_link;
  link.open_action.call( link );
};
#{ensure_termination(onclick_handler(controller,link_id))}
return false;
END
    # script = "window.gModalLink = $('#{link_id}').action_link;#{onclick_handler(controller,link_id)}return false;"
  end
  
  def onclick_handler( controller, link_id )
    ""
  end
  
protected
  def ensure_termination( expression )
    expression =~ /;$/ ? expression : "#{expression};"
  end
  
end

