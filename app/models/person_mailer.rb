class PersonMailer < ActionMailer::Base
  extend PreferencesHelper
  
  def domain
    @domain ||= PersonMailer.global_prefs.domain
  end
  
  def server
    @server_name ||= PersonMailer.global_prefs.server_name
  end
  
  def password_reset_instructions(person)
    subject      "Password Reset Instructions"
    from         "Password reset <password_reset@#{domain}>"
    recipients   person.email
    content_type "text/html"
    sent_on      Time.now
    body         :edit_password_reset_url => edit_password_reset_url(person.perishable_token)
  end

  def message_notification(message)
    from         "Message notification <message@#{domain}>"
    recipients   message.recipient.email
    subject      formatted_subject(message.subject)
    content_type "text/html"
    body         "domain" => server, "message" => message,
    "preferences_note" => preferences_note(message.recipient)
  end
  
  def connection_request(connection)
    from         "Contact request <connection@#{domain}>"
    recipients   connection.person.email
    subject      formatted_subject("New contact request")
    body         "domain" => server,
    "connection" => connection,
    "url" => edit_connection_path(connection),
    "preferences_note" => preferences_note(connection.person)
  end
  
  def membership_public_group(membership)
    from         "Membership done <membership@#{domain}>"
    recipients   membership.group.owner.email
    subject      formatted_subject("New member in group #{membership.group.name}")
    body         "domain" => server,
    "membership" => membership,
    "url" => members_group_path(membership.group),
    "preferences_note" => preferences_note(membership.group.owner)
  end
  
  def membership_request(membership)
    from         "Membership request <membership@#{domain}>"
    recipients   membership.group.owner.email
    subject      formatted_subject("Membership request for group #{membership.group.name}")
    body         "domain" => server,
    "membership" => membership,
    "url" => members_group_path(membership.group),
    "preferences_note" => preferences_note(membership.group.owner)
  end
  
  def membership_accepted(membership)
    from         "Membership accepted <membership@#{domain}>"
    recipients   membership.person.email
    subject      formatted_subject("You have been accepted to join #{membership.group.name}")
    body         "domain" => server,
    "membership" => membership,
    "url" => group_path(membership.group),
    "preferences_note" => preferences_note(membership.person)
  end
  
  def invitation_notification(membership)
    from         "Invitation notification <invitation#{domain}>"
    recipients   membership.person.email
    subject      formatted_subject("Invitation from group #{membership.group.name}")
    body         "domain" => server,
    "membership" => membership,
    "url" => edit_membership_path(membership),
    "preferences_note" => preferences_note(membership.person)
  end
  
  def invitation_accepted(membership)
    from         "Invitation accepted <invitation@#{domain}>"
    recipients   membership.group.owner.email
    subject      formatted_subject("#{membership.person.name} accepted the invitation")
    body         "domain" => server,
    "membership" => membership,
    "url" => members_group_path(membership.group),
    "preferences_note" => preferences_note(membership.group.owner)
  end
  
  def blog_comment_notification(comment)
    from         "Comment notification <comment@#{domain}>"
    recipients   comment.commented_person.email
    subject      formatted_subject("New blog comment")
    body         "domain" => server, "comment" => comment,
    "url" => 
      blog_post_path(comment.commentable.blog, comment.commentable),
    "preferences_note" => 
      preferences_note(comment.commented_person)
  end
  
  def wall_comment_notification(comment)
    from         "Comment notification <comment@#{domain}>"
    recipients   comment.commented_person.email
    subject      formatted_subject("New wall comment")
    body         "domain" => server, "comment" => comment,
    "url" => person_path(comment.commentable, :anchor => "wall"),
    "preferences_note" => 
      preferences_note(comment.commented_person)
  end
  
  def forum_post_notification(subscriber, forum_post)
    from         "#{forum_post.person.name} <forum@#{domain}>"
    recipients   subscriber.email
    subject      formatted_group_subject(forum_post.topic.forum.group, forum_post.topic.name)
    content_type "text/html"
    body         "domain" => server, "forum_post" => forum_post,
    "preferences_note" => 
      preferences_note(subscriber)
  end

  def email_verification(ev)
    from         "Email verification <email@#{domain}>"
    recipients   ev.person.email
    subject      formatted_subject("Email verification")
    body         "server_name" => server,
    "code" => ev.code
  end

  def registration_notification(new_peep)
    from         "Registration notification <registration@#{domain}>"
    recipients   PersonMailer.global_prefs.new_member_notification.split
    subject      formatted_subject("New registration")
    body         "email" => new_peep.email,
    "name" => new_peep.name,
    "domain" => server,
    "url" => person_path(new_peep)
  end

  def req_notification(req, recipient)
    from         "Request notification <request@#{domain}>"
    recipients   recipient.email
    subject      formatted_subject("New request matches your profile")
    body         "name" => req.name,
    "description" => req.description,
    "domain" => server,
    "url" => req_path(req)
  end
  
  private
  
  # Prepend the application name to subjects if present in preferences.
  def formatted_subject(text)
    name = PersonMailer.global_prefs.app_name
    label = name.blank? ? "" : "[#{name}] "
    "#{label}#{text}"
  end

  def formatted_group_subject(group,text)
    if !group
      formatted_subject(text)
    else
      "[#{group.name}] #{text}"
    end
  end
  
  def preferences_note(person)
    %(To change your email notification preferences, visit
      
http://#{server}/people/#{person.to_param}/edit)
  end

end
