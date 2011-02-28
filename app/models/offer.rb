class Offer < ActiveRecord::Base
  include ActivityLogger

  index do 
    name
    description
  end

  named_scope :with_group_id, lambda {|group_id| {:conditions => ['group_id = ?', group_id]}}
  named_scope :search, lambda { |text| {:conditions => ["lower(name) LIKE ? OR lower(description) LIKE ?","%#{text}%".downcase,"%#{text}%".downcase]} }

  has_and_belongs_to_many :categories
  has_many :exchanges, :as => :metadata
  belongs_to :person
  belongs_to :group
  attr_protected :person_id, :created_at, :updated_at
  attr_readonly :group_id
  validates_presence_of :name, :expiration_date
  validates_presence_of :total_available
  validates_presence_of :group_id

  after_create :log_activity

  class << self

    def current(page=1)
      today = DateTime.now
      Offer.paginate(:all, :page => page, :conditions => ["available_count > ? AND expiration_date >= ?", 0, today], :order => 'created_at DESC')
    end

    def categorize(category,group,page,posts_per_page,search=nil)
      unless category
        group.offers.search(search).paginate(:page => page, :per_page => posts_per_page)
      else
        category.offers.with_group_id(group.id).paginate(:page => page, :per_page => posts_per_page)
      end
    end
  end

  def can_destroy?
    self.exchanges.length == 0
  end

  def log_activity
    add_activities(:item => self, :person => self.person, :group => self.group)
  end

  def unit
    group.unit
  end

  def formatted_categories
    categories.collect {|cat| cat.long_name + "<br>"}.to_s.chop.chop.chop.chop
  end
  
  private

  def validate
    if self.categories.length > 5
      errors.add_to_base('Only 5 categories are allowed per offer')
    end

    unless self.group.nil?
      unless self.group.adhoc_currency?
        errors.add(:group_id, "does not have its own currency")
      end
      unless person.groups.include?(self.group)
        errors.add(:group_id, "does not include you as a member")
      end
    end
  end
end
