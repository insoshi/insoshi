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

  def send_forum_post_mailing(options)
    @forum_post = ForumPost.find(options[:forum_post_id])
    peeps = Person.all_listening_to_forum_posts
    peeps.each do |peep|
      logger.info("MailingsWorker forum_post: sending email to #{peep.id}: #{peep.name}")
      PersonMailer.deliver_forum_post_notification(peep,@forum_post)
    end
  end
end
