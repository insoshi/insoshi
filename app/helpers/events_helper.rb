module EventsHelper

  # Given an event, return a message for the feed for the event's class.
  def feed_message(event)
    person = link_to(event.person.name, event.person)
    case event.class.to_s
    when "BlogPostEvent"
      blog = event.post.blog
      post_title = link_to(event.post.title, blog_post_path(blog, event.post))
      msg = "#{person} has made a new blog post:<br /> #{post_title}"
    when "ConnectionEvent"
      contact = link_to(event.conn.contact.name, event.conn.contact)
      msg = "#{person} and #{contact} have connected"
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
