class PersonMailer < ActionMailer::Base
  extend PreferencesHelper
  
  DOMAIN = PersonMailer.preferences.email_domain
  
  def password_reminder(person)
    from         "Password reminder <password-reminder@#{DOMAIN}>"
    recipients   person.email
    subject      "Password reminder"
    body         "person" => person
  end
  
  def message_notification(message)
    from         "Message notification <message@#{DOMAIN}>"
    recipients   message.recipient.email
    subject      "New message"
    body         "message" => message
  end
  
  def connection_request(person, contact)
    from         "Contact request <connection@#{DOMAIN}>"
    recipients   person.email
    subject      "New contact request"
    body         "contact" => contact
  end
end
