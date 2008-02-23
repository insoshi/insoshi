class MessageReceiptMailer < ActionMailer::Base
  def reminder(message)
    from         "MeWorthy <no-reply@meworthy.com>"
    recipients   message.recipient.email
    subject      "New MeWorthy message!"
    body         "message" => message
  end
end
