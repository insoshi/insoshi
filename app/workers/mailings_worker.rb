class MailingsWorker < Workling::Base
  def send_mailing(options)
    @broadcast_email = BroadcastEmail.find(options[:mailing_id])
    peeps = Person.all_active
    peeps.each do |peep|
      logger.info("MailingsWorker: sending email to #{peep.id}: #{peep.name}")
      email = BroadcastMailer.create_spew(peep, @broadcast_email.subject, @broadcast_email.message)
      email.set_content_type("text/html")
      BroadcastMailer.deliver(email)
    end

  end
end
