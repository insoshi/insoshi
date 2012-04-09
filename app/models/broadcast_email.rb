# == Schema Information
# Schema version: 20090216032013
#
# Table name: broadcast_emails
#
#  id         :integer(4)      not null, primary key
#  subject    :string(255)
#  message    :text
#  created_at :datetime
#  updated_at :datetime
#

class BroadcastEmail < ActiveRecord::Base

  def perform
    peeps = Person.all_broadcast_email
    peeps.each do |peep|
      logger.info("BroadcaseEmail: sending email to #{peep.id}: #{peep.name}")
      email = BroadcastMailer.create_spew(peep, subject, message)
      email.set_content_type("text/html")
      BroadcastMailer.deliver(email)
    end
  end

end
