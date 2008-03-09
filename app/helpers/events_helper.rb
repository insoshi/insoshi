module EventsHelper

  # Given an event, return a message for the feed for the event's class.
  def feed_message(event)
    person = event.person
    # Switch on the class.to_s.  (The class itself is long & complicated.)
    case event.class.to_s
    when "BlogPostEvent"
      blog = event.post.blog
      view_blog = link_to("View #{person.name}'s blog", blog)
      msg = %(#{person_link(person)} made a blog post titled
              #{post_link(blog, event.post)}.
              <br /> #{view_blog})
    when "BlogPostCommentEvent"
      post = event.comment.post
      blog = post.blog
      someones = current_person?(blog.person) ? 
                 "their own" :
                 "#{person_link(blog.person)}'s"
      msg = %(#{person_link(person)} made a comment to
              #{someones} blog post #{post_link(blog, post)})
    when "ConnectionEvent"
      contact_link = link_to(event.conn.contact.name, event.conn.contact)
      msg = %(#{person_link(person)} and #{person_link(event.conn.contact)}
              have connected)
    else
      "bar"
    end
    message_row(event, msg)
  end

  def person_link(person)
    link_to(person.name, person)
  end
  
  def post_link(blog, post)
    link_to(post.title, blog_post_path(blog, post))
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
