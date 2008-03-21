class PersonMailer < ActionMailer::Base
  def password_reminder(person)
    from         "Password reminder <password-reminder@#{EMAIL_DOMAIN}>"
    recipients   person.email
    subject      "Password reminder"
    body         "person" => person
  end
  
  def message_notification(message)
    from         "Message notification <message@#{EMAIL_DOMAIN}>"
    recipients   message.recipient.email
    subject      "New message"
    body         "message" => message
  end
  
  def connection_request(person, contact)
    from         "Contact request <connection@#{EMAIL_DOMAIN}>"
    recipients   person.email
    subject      "New contact request"
    body         "contact" => contact
  end
end
