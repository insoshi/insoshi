class EmailVerification < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :person_id, :code
  before_validation :make_code
  
  private
  
    def make_code
      self.code = UUID.new
    end
end
