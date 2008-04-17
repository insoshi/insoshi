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
  
  def connection_request(person, contact)
    from         "Contact request <connection@#{domain}>"
    recipients   person.email
    subject      "New contact request"
    body         "domain" => domain, "contact" => contact
  end
  
  def email_verification(ev)
    from         "Email verification <email@#{domain}>"
    recipients   ev.person.email
    subject      "Email verification"
    body         "domain" => domain, "code" => ev.code
  end
end
