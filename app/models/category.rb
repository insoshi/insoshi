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

  has_and_belongs_to_many :reqs
  has_and_belongs_to_many :offers
  has_and_belongs_to_many :people
  acts_as_tree

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

  def active_people
    active_people = self.people.find(:all, :conditions => Person.conditions_for_active)
  end

  def current_and_active_reqs
    today = DateTime.now
    reqs = self.reqs.find(:all, :conditions => ["active = ? AND due_date >= ?", true, today], :order => 'created_at DESC')
    reqs.delete_if { |req| req.has_approved? }
  end

  def descendants_current_and_active_reqs_count
    descendants.map {|d| d.current_and_active_reqs.length}.inject(0) {|sum,element| sum + element}
  end

  def descendants_providers_count
    # not going to the trouble of making sure people are counted only once
    descendants.map {|d| d.active_people.length}.inject(0) {|sum,element| sum + element}
  end
end
