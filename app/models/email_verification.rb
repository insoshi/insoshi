# == Schema Information
# Schema version: 20090216032013
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
