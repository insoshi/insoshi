require 'texticle/searchable'

class Category < ActiveRecord::Base
  LONG_NAME_SEPARATOR = ":"
  extend Searchable(:name, :description)

  validates_presence_of :name
  has_and_belongs_to_many :reqs
  has_and_belongs_to_many :offers
  has_and_belongs_to_many :people
  acts_as_tree

  def self.root_nodes
    where(:parent_id => nil).order(:name)
  end

  def descendant_ids
    children_only_id = children.select("id")
    children_only_id.collect(&:descendant_ids).flatten + children_only_id
  end

  # return all records using a preload strategy to calculate the long names
  def self.by_long_name
    all_records = all.to_a
    all_records.sort_by {|r| r.long_name(all_records)}
  end

  # Calculate the long_name using the ancestors.
  #
  # If an optional list of preloaded parents is given, then no DB call is done
  # (except for the one used to preload the parents)
  #
  # Otherwise each parent is loaded separately from the DB, giving rise
  # to up to N^2 queries to load all long_names of all records in a balanced
  # tree.
  def long_name(preloaded=nil)
    @long_name ||= begin
      if preloaded
        _parent = preloaded.detect { |r| r.id == self.parent_id }
        [_parent.try(:long_name, preloaded), name].compact
      else
        (ancestors.reverse << self).collect(&:name)
      end.join(LONG_NAME_SEPARATOR)
    end
  end

  def current_and_active_reqs
    reqs.current
  end

  def descendants_current_and_active_reqs_count
    Req.current.biddable.for_category(descendant_ids).count
  end

  def descendants_providers_count
    Person.active.joins(:categories).where(:'categories.id' => descendant_ids).count
  end
end
