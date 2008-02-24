class PersonMailer < ActionMailer::Base
  # TODO: get the return domain right
  def password_reminder(person)
    from         "Password reminder <password-reminder@example.com>"
    recipients   person.email
    subject      "Password reminder"
    body         "person" => person
  end
  
  # TODO: get the return domain right
  def message_notification(message)
    from         "Message notification <message@example.com>"
    recipients   message.recipient.email
    subject      "New message"
    body         "message" => message
  end
  
  def connection_request(person, contact)
    from         "Connection request <connection@example.com>"
    recipients   person.email
    subject      "New contact request"
    body         "contact" => contact
  end
end
