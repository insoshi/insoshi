class PopulateCategories < ActiveRecord::Migration
  def self.up
    Category.reset_column_information
    CATEGORIES.each do |value|
      category = Category.new( :name => value, :description => "" )
      category.save
    end
  end

  def self.down
  end

  CATEGORIES = [
"Arts & Crafts",
"Building Services",
"Business & Administration",
"Children & Childcare",
"Computers",
"Counseling & Therapy",
"Food",
"Gardening & Yard Work",
"Goods",
"Health & Personal",
"Household",
"Miscellaneous",
"Music & Entertainment",
"Pets",
"Sports & Recreation",
"Teaching",
"Transportation",
"Freebies",
"Education"
  ]
end
