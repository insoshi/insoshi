class Offer < ActiveRecord::Base
  include ActivityLogger

  index do 
    name
    description
  end

  has_and_belongs_to_many :categories
  has_many :exchanges, :as => :metadata
  belongs_to :person
  attr_protected :person_id, :created_at, :updated_at
  validates_presence_of :name, :expiration_date
  validates_presence_of :total_available
  after_create :log_activity

  class << self

    def current(page=1)
      today = DateTime.now
      Offer.paginate(:all, :page => page, :conditions => ["available_count > ? AND expiration_date >= ?", 0, today], :order => 'created_at DESC')
    end

  end

  def can_destroy?
    self.exchanges.length == 0
  end

  def log_activity
    add_activities(:item => self, :person => self.person)
  end

  def formatted_categories
    categories.collect {|cat| cat.long_name + "<br>"}.to_s.chop.chop.chop.chop
  end
end
