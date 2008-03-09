module EventsHelper

  # Given an event, return a message for the feed for the event's class.
  def feed_message(event)
    case event.class.to_s
    when "ConnectionEvent"
      link_1 = link_to(event.person.name, event.person)
      link_2 = link_to(event.conn.contact.name, event.conn.contact)
      msg = "#{link_1} and #{link_2} have connected"
    else
      "bar"
    end
    message_row(event, msg)
  end

  
  private
  
    # Return a standard row element for a feed message.
    def message_row(event, message)
      markaby do
        tr do
          person = event.person
          td { link_to(image_tag(person.icon), person) }
          td { message }
        end
      end      
    end
end
