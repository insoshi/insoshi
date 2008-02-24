class MessageReceiptMailer < ActionMailer::Base
  # TODO: get the return domain right
  def reminder(message)
    from         "Message reminder <no-reply@example.com>"
    recipients   message.recipient.email
    subject      "New message!"
    body         "message" => message
  end
end
