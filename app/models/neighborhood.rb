class Neighborhood < ActiveRecord::Base
  has_and_belongs_to_many :reqs, :order => 'created_at DESC'
  has_and_belongs_to_many :offers, :order => 'created_at DESC'
  has_and_belongs_to_many :people
  acts_as_tree

#  def reqs
#    Req.scoped(:joins => {:person => :neighborhoods },
#               :conditions => {:neighborhoods => {:id => self.id}}
#               )
#  end

#  def offers
#    Offer.scoped(:joins => {:person => :neighborhoods },
#               :conditions => {:neighborhoods => {:id => self.id}}
#               )
#  end

  def ancestors_name
    if parent
      parent.ancestors_name + parent.name + ':'
    else
      ""
    end
  end

  def long_name
    ancestors_name + name
  end
end
