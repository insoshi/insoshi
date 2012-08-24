class PersonMailer < ActionMailer::Base
  extend PreferencesHelper
  helper :application
  include CoreHelper

  def domain
    @domain ||= (ENV['SMTP_DOMAIN'] || ENV['DOMAIN'])
  end
  
  def server
    @server ||= PersonMailer.global_prefs.server_name
  end
  
  def password_reset_instructions(person)
    person = coerce(person, Person)
    @edit_password_reset_url = edit_password_reset_url(person.perishable_token)
    mail(:to => person.email,
         :from => "Password reset <password_reset@#{domain}>",
         :subject => formatted_subject("Password reset")
        )
  end

  def message_notification(message)
    message = coerce(message, Message)
    @message = message
    @server = server
    @preferences_note = preferences_note(message.recipient)
    mail(:to => message.recipient.email,
         :from => "Message notification <message@#{domain}>",
         :subject => formatted_subject(message.subject)
        )
  end

  def membership_public_group(membership)
    membership = coerce(membership, Membership)
    @membership = membership
    @server = server
    @url = members_group_path(membership.group)
    @preferences_note = preferences_note(membership.group.owner)
    mail(:to => membership.group.admins.map {|m| m.email},
         :from => "Membership done <membership@#{domain}>",
         :subject => formatted_subject("#{membership.person.name} joined group #{membership.group.name}")
        )
  end
  
  def membership_request(membership)
    membership = coerce(membership, Membership)
    @membership = membership
    @server = server
    @url = members_group_path(membership.group)
    @preferences_note = preferences_note(membership.group.owner)
    mail(:to => membership.group.admins.map {|m| m.email},
         :from => "Membership request <membership@#{domain}>",
         :subject => formatted_subject("#{membership.person.name} wants to join group #{membership.group.name}")
        )
  end
  
  def membership_accepted(membership)
    membership = coerce(membership, Membership)
    @membership = membership
    @server = server
    @url = group_path(membership.group)
    @preferences_note = preferences_note(membership.person)
    mail(:to => membership.person.email,
         :from => "Membership accepted <membership@#{domain}>",
         :subject => formatted_subject("You have been accepted to join #{membership.group.name}")
        )
  end
  
  def forum_post_notification(subscriber, forum_post)
    subscriber = coerce(subscriber, Person)
    forum_post = coerce(forum_post, ForumPost)
    @forum_post = forum_post
    @server = server
    @preferences_note = forum_preferences_note(subscriber, forum_post.topic.forum.group)

    mail(:to => subscriber.email,
         :from => "#{forum_post.person.name} <forum@#{domain}>",
         :subject => formatted_group_subject(forum_post.topic.forum.group, forum_post.topic.name)
        )
  end

  def email_verification(person)
    person = coerce(person, Person)
    @server_name = server
    @code = person.perishable_token
    mail(:to => "#{person.name} <#{person.email}>", 
         :from => "Email verification <email@#{domain}>",
         :subject => formatted_subject("Email verification")
        )
  end

  def registration_notification(person)
    person = coerce(person, Person)
    @server_name = server
    @person = person

    @url = person_path(person)
    mail(:to => recipients_of_registration_notifications,
         :from => "Registration notification <registration@#{domain}>",
         :subject => formatted_subject("New registration")
        )
  end

  def req_notification(req, recipient)
    req = coerce(req, Req)
    recipient = coerce(recipient, Person)
    @req = req
    mail(:to => recipient.email,
         :from => "Request notification <request@#{domain}>",
         :subject => formatted_subject("Request: #{req.name}")
        )
  end
  
  private
  
  def recipients_of_registration_notifications
    recipients = []
    if PersonMailer.global_prefs.whitelist?
      recipients += Person.all(:conditions => ['activator = ?',true]).map {|p| p.email}
    end
    recipients += PersonMailer.global_prefs.new_member_notification.split
  end

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

  def forum_preferences_note(person,group)
    %(To change your forum notification preferences for this group, visit
      
http://#{server}/groups/#{group.id}#member_preferences/#{Membership.mem(person,group).member_preference.id}/edit)
  end

end
