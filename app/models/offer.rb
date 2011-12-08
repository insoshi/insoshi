class Offer < ActiveRecord::Base
  include ActivityLogger

  index do 
    name
    description
  end

  named_scope :with_group_id, lambda {|group_id| {:conditions => ['group_id = ?', group_id]}}
  named_scope :search, lambda { |text| {:conditions => ["lower(name) LIKE ? OR lower(description) LIKE ?","%#{text}%".downcase,"%#{text}%".downcase]} }
  named_scope :active, :conditions => ["available_count > ? AND expiration_date >= ?", 0, DateTime.now]

  has_and_belongs_to_many :categories
  has_and_belongs_to_many :neighborhoods
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
    def search(category,group,active_only,page,posts_per_page,search=nil)
      unless category
        chain = group.offers
        chain = chain.search(search) if search
      else
        chain = category.offers.with_group_id(group.id)
      end

      chain = chain.active if active_only
      chain.paginate(:page => page, :per_page => posts_per_page)
    end
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
