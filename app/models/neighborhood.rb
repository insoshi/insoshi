class Neighborhood < ActiveRecord::Base
  LONG_NAME_SEPARATOR = ":"
  validates_presence_of :name
  has_and_belongs_to_many :reqs, :order => 'created_at DESC'
  has_and_belongs_to_many :offers, :order => 'created_at DESC'
  has_and_belongs_to_many :people
  acts_as_tree

  def reqs
    Req.joins(:person => :neighborhoods).where "neighborhoods.id" => self.id
  end

  def offers
    Offer.joins(:person => :neighborhoods).where "neighborhoods.id" => self.id
  end

  def long_name
    (ancestors.reverse << self).collect(&:name).join(":")
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

end
