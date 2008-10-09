# == Schema Information
# Schema version: 20080916002106
#
# Table name: email_verifications
#
#  id         :integer(4)      not null, primary key
#  person_id  :integer(4)      
#  code       :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class EmailVerification < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :person_id, :code
  before_validation_on_create :make_code
  after_create :send_verification_email
  
  private
  
    # Make a unique verification code.
    def make_code
      self.code = UUID.new
    end
    
    def send_verification_email
      PersonMailer.deliver_email_verification(self)
    end
end
