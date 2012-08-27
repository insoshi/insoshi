# == Schema Information
# Schema version: 20090216032013
#
# Table name: categories
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)     
#  description :text            
#  parent_id   :integer(4)      
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Category < ActiveRecord::Base

  index do 
    name description
  end

  validates_presence_of :name
  has_and_belongs_to_many :reqs, :conditions => "biddable IS true", :order => 'created_at DESC'
  has_and_belongs_to_many :offers, :order => 'created_at DESC'
  has_and_belongs_to_many :people, :conditions => Person.conditions_for_active
  acts_as_tree

  def self.root_nodes
    all(:conditions => "parent_id is NULL").sort_by {|a| a.name}
  end

  def descendants
    children.map(&:descendants).flatten + children
  end

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

  def current_and_active_reqs
    reqs.current.biddable.order('created_at DESC')
  end

  def descendants_current_and_active_reqs_count
    descendants.map {|d| d.current_and_active_reqs.length}.inject(0) {|sum,element| sum + element}
  end

  def descendants_providers_count
    # not going to the trouble of making sure people are counted only once
    descendants.map {|d| d.people.length}.inject(0) {|sum,element| sum + element}
  end
end
