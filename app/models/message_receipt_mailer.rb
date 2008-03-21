class MessageReceiptMailer < ActionMailer::Base
  def reminder(message)
    from         "Message reminder <message-reminder@#{EMAIL_DOMAIN}>"
    recipients   message.recipient.email
    subject      "New message!"
    body         "message" => message
  end
end
