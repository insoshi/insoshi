class Offer < ActiveRecord::Base
  include ActivityLogger

  has_and_belongs_to_many :categories
  belongs_to :person
  attr_protected :person_id, :created_at, :updated_at
  validates_presence_of :name
  after_create :log_activity

  class << self

    def current(page=1)
      today = DateTime.now
      @reqs = Offer.paginate(:all, :page => page, :conditions => ["expiration_date >= ?", today], :order => 'created_at DESC')
    end

  end

  def log_activity
    add_activities(:item => self, :person => self.person)
  end

  def formatted_categories
    categories.collect {|cat| cat.long_name + "<br>"}.to_s.chop.chop.chop.chop
  end
end
