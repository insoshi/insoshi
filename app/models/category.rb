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

  is_indexed :fields => ['name', 'description']

  has_and_belongs_to_many :reqs
  has_and_belongs_to_many :people
  acts_as_tree

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
