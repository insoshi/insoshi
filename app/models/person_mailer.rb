class PersonMailer < ActionMailer::Base
  extend PreferencesHelper
  
  def domain
    @domain ||= PersonMailer.global_prefs.email_domain
  end
  
  def password_reminder(person)
    from         "Password reminder <password-reminder@#{domain}>"
    recipients   person.email
    subject      "Password reminder"
    body         "person" => person
  end
  
  def message_notification(message)
    from         "Message notification <message@#{domain}>"
    recipients   message.recipient.email
    subject      "New message"
    body         "message" => message
  end
  
  def connection_request(person, contact)
    from         "Contact request <connection@#{domain}>"
    recipients   person.email
    subject      "New contact request"
    body         "contact" => contact
  end
end
