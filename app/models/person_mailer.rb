class PersonMailer < ActionMailer::Base
  extend PreferencesHelper
  
  def domain
    @domain ||= PersonMailer.global_prefs.domain
  end
  
  def password_reminder(person)
    from         "Password reminder <password-reminder@#{domain}>"
    recipients   person.email
    subject      "Password reminder"
    body         "domain" => domain, "person" => person
  end
  
  def message_notification(message)
    from         "Message notification <message@#{domain}>"
    recipients   message.recipient.email
    subject      "New message"
    body         "domain" => domain, "message" => message
  end
  
  def connection_request(connection)
    from         "Contact request <connection@#{domain}>"
    recipients   connection.contact.email
    subject      "New contact request"
    body         "domain" => domain,
                 "connection" => connection,
                 "url" => edit_connection_path(connection),
                 "preferences_note" => preferences_note(connection.contact)
  end
  
  def blog_comment_notification(comment)
    from         "Comment notification <comment@#{domain}>"
    recipients   comment.commented_person.email
    subject      "New blog comment"
    body         "domain" => domain, "comment" => comment,
                 "url" => 
                 blog_post_path(comment.commentable.blog, comment.commentable),
                 "preferences_note" => 
                    preferences_note(comment.commented_person)
  end
  
  def wall_comment_notification(comment)
    from         "Comment notification <comment@#{domain}>"
    recipients   comment.commented_person.email
    subject      "New blog comment"
    body         "domain" => domain, "comment" => comment,
                 "url" => person_path(comment.commentable, :anchor => "wall"),
                 "preferences_note" => 
                    preferences_note(comment.commented_person)
  end
  
  def email_verification(ev)
    name = PersonMailer.global_prefs.app_name
    label = name.nil? || name.blank? ? "" : "[#{name}] "
    from         "Email verification <email@#{domain}>"
    recipients   ev.person.email
    subject      "#{label}Email verification"
    body         "server_name" => PersonMailer.global_prefs.server_name,
                 "code" => ev.code
  end
  
  private
  
    def preferences_note(person)
      %(To change your email notification preferences, visit
      
http://#{domain}/people/#{person.to_param}/edit)
    end
end
