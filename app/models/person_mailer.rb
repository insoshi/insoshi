class PersonMailer < ActionMailer::Base
  extend PreferencesHelper
  
  def domain
    @domain ||= PersonMailer.global_prefs.domain
  end
  
  def server
    @server_name ||= PersonMailer.global_prefs.server_name
  end
  
  def password_reminder(person)
    from         "Password reminder <password-reminder@#{server}>"
    recipients   person.email
    subject      formatted_subject("Password reminder")
    body         "domain" => server, "person" => person
  end
  
  def message_notification(message)
    from         "Message notification <message@#{server}>"
    recipients   message.recipient.email
    subject      formatted_subject("New message")
    body         "domain" => server, "message" => message
  end
  
  def connection_request(connection)
    from         "Contact request <connection@#{server}>"
    recipients   connection.contact.email
    subject      formatted_subject("New contact request")
    body         "domain" => server,
                 "connection" => connection,
                 "url" => edit_connection_path(connection),
                 "preferences_note" => preferences_note(connection.contact)
  end
  
  def blog_comment_notification(comment)
    from         "Comment notification <comment@#{server}>"
    recipients   comment.commented_person.email
    subject      formatted_subject("New blog comment")
    body         "domain" => server, "comment" => comment,
                 "url" => 
                 blog_post_path(comment.commentable.blog, comment.commentable),
                 "preferences_note" => 
                    preferences_note(comment.commented_person)
  end
  
  def wall_comment_notification(comment)
    from         "Comment notification <comment@#{server}>"
    recipients   comment.commented_person.email
    subject      formatted_subject("New wall comment")
    body         "domain" => server, "comment" => comment,
                 "url" => person_path(comment.commentable, :anchor => "wall"),
                 "preferences_note" => 
                    preferences_note(comment.commented_person)
  end
  
  def email_verification(ev)
    from         "Email verification <email@#{server}>"
    recipients   ev.person.email
    subject      formatted_subject("Email verification")
    body         "server_name" => server,
                 "code" => ev.code
  end
  
  private
  
    # Prepend the application name to subjects if present in preferences.
    def formatted_subject(text)
      name = PersonMailer.global_prefs.app_name
      label = name.blank? ? "" : "[#{name}] "
      "#{label}#{text}"
    end
  
    def preferences_note(person)
      %(To change your email notification preferences, visit
      
http://#{server}/people/#{person.to_param}/edit)
    end
end
