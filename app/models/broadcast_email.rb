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

  def spew
    peeps = Person.active.broadcast_email
    after_transaction do
      peeps.each do |peep|
        logger.info("BroadcastEmail: sending email to #{peep.id}: #{peep.name}")
        BroadcastMailerQueue.spew(peep, subject, message)
      end
    end
  end

end
