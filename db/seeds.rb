# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

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

CATEGORIES.each do |value|
  category = Category.find_or_create_by_name(value, :description => "")
end
