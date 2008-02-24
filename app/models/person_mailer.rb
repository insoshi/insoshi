class PersonMailer < ActionMailer::Base
  # TODO: get the return domain right
  def reminder(person)
    from         "Reminder <password-reminder@example.com>"
    recipients   person.email
    subject      "Password reminder"
    body         "person" => person
  end
end
