class Category < ActiveRecord::Base
  has_and_belongs_to_many :reqs
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
