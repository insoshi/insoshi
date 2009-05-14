module ActionView
  module Helpers
    module FormOptionsHelper

      # Return a full select and option tags for the given object and method, using usa_state_options_for_select to generate the list of option <tags>.
      def usa_state_select(object, method, priority_states = nil, options = {}, html_options = {})
        InstanceTag.new(object, method, self, nil, options.delete(:object)).to_usa_state_select_tag(priority_states, options, html_options)
      end
    

      # Returns a string of option tags for the states in the United States. Supply a state name as +selected to
      # have it marked as the selected option tag. Included also is the option to set a couple of +priority_states+ 
      # in case you want to highligh a local area
      # NOTE: Only the option tags are returned from this method, wrap it in a <select>
      def usa_state_options_for_select(selected = nil, priority_states = nil)
        state_options = ""
        if priority_states
          state_options += options_for_select(priority_states, selected)
          state_options += "<option>-------------</option>\n"
        end

        if priority_states && priority_states.include?(selected)
          state_options += options_for_select(USASTATES - priority_states, selected)
        else
          state_options += options_for_select(USASTATES, selected)
        end

        return state_options
      end

    	USASTATES = [["Alabama", "AL"], ["Alaska", "AK"], ["Arizona", "AZ"], ["Arkansas", "AR"], ["California", "CA"], ["Colorado", "CO"], ["Connecticut", "CT"], ["Delaware", "DE"], ["District of Columbia", "DC"], ["Florida", "FL"], ["Georgia", "GA"], ["Hawaii", "HI"], ["Idaho", "ID"], ["Illinois", "IL"], ["Indiana", "IN"], ["Iowa", "IA"], ["Kansas", "KS"], ["Kentucky", "KY"], ["Louisiana", "LA"], ["Maine", "ME"], ["Maryland", "MD"], ["Massachusetts", "MA"], ["Michigan", "MI"], ["Minnesota", "MN"], ["Mississippi", "MS"], ["Missouri", "MO"], ["Montana", "MT"], ["Nebraska", "NE"], ["Nevada", "NV"], ["New Hampshire", "NH"], ["New Jersey", "NJ"], ["New Mexico", "NM"], ["New York", "NY"], ["North Carolina", "NC"], ["North Dakota", "ND"], ["Ohio", "OH"], ["Oklahoma", "OK"], ["Oregon", "OR"], ["Pennsylvania", "PA"], ["Rhode Island", "RI"], ["South Carolina", "SC"], ["South Dakota", "SD"], ["Tennessee", "TN"], ["Texas", "TX"], ["Utah", "UT"], ["Vermont", "VT"], ["Virginia", "VA"], ["Washington", "WA"], ["Wisconsin", "WI"], ["West Virginia", "WV"], ["Wyoming", "WY"]] unless const_defined?("USASTATES")
 
    end
  
    class InstanceTag #:nodoc:
      include FormOptionsHelper
 
      def to_usa_state_select_tag(priority_states, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object) if method(:value).arity > 0
        content_tag("select", add_options(usa_state_options_for_select(value, priority_states), options, value), html_options)
      end
    end
  end
end