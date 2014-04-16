# Common behavior between offers and requests

module AnnouncementBase
  extend ActiveSupport::Concern

  included do

    attr_protected :person_id, :created_at, :updated_at
    attr_readonly :group_id

    belongs_to :person
    belongs_to :group
    has_many :exchanges, :as => :metadata
    has_and_belongs_to_many :categories
    has_and_belongs_to_many :neighborhoods

    validates :group_id, :name, :presence => true
    validate :group_includes_person_as_a_member
    validate :maximum_categories

    after_create :log_activity

    delegate :unit, :to => :group

    extend AnnouncementBase::Scopes

  end

  module Scopes
    def for_group(group)
      group = group.id if group.is_a? Group
      where(:group_id => group)
    end

    def for_filter(filter)
      if filter.is_a? Category
        includes(:categories).where(:'categories.id' => filter.id)
      elsif filter.is_a? Neighborhood
        includes(:neighborhoods).where(:'neighborhoods.id' => filter.id)
      end
    end

    def search_by(text)
      where(arel_table[:name].matches("%#{text}%").or(arel_table[:description].matches("%#{text}%")))
    end

    def for_active_person
      joins(:person)
      .where(:people => {:deactivated => false})
    end

    def custom_search(filter, group, active_only, page, posts_per_page, search=nil)
      rel = self
      rel = rel.for_filter(filter) if filter
      rel = rel.for_group(group) if group
      rel = rel.search_by(search) if search
      rel = rel.active if active_only
      rel = rel.for_active_person
      rel.paginate(:page => page, :per_page => posts_per_page)
    end

  end

  def maximum_categories
    errors.add(:base, "Only 5 categories are allowed") if categories.length > 5
  end

  def group_has_a_currency
    return unless group
    errors.add(:group_id, "does not have its own currency") unless group.adhoc_currency?
  end

  def group_includes_person_as_a_member
    return unless group
    errors.add(:group_id, "does not include you as a member") unless person.groups.include?(group)
  end

  def long_categories
    categories.map {|cat| cat.long_name }
  end

  def log_activity
    add_activities(:item => self, :person => self.person, :group => self.group)
  end

end
