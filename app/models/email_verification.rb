# == Schema Information
#
# Table name: email_verifications
#
#  id         :integer          not null, primary key
#  person_id  :integer
#  code       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EmailVerification < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :person_id, :code
  before_validation :make_code, :on => :create
  after_create :send_verification_email
  
  private
  
    # Make a unique verification code.
    def make_code
      self.code = UUID.new
    end
    
    def send_verification_email
      after_transaction { PersonMailerQueue.email_verification(self) }
    end
end
