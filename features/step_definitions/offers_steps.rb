Given /^a category named Vegetables\:Beans$/ do
  init_oscurrency

  @vegetables_category = Category.create!(:name => "Vegetables")
  @beans_category = Category.new(:name => "Beans")
  @beans_category.parent = @vegetables_category
  @beans_category.save!
end

When /^I create an offer Green Beans in the Vegetables\:Beans category$/ do
  current_person = Person.find(:first)
  #visit offers_path
  #click_button "add offer" XXX this button has javascript so webrat won't find it
  visit new_offer_path
  fill_in "offer_name", :with => "Green Beans"
  select "Vegetables:Beans", :from => "offer_category_ids"
  click_button "Create"
end

Then /^Green Beans should be in the Vegetables category$/ do
  visit categories_path
  click_link "Beans"
  response.should contain("Green Beans")
end

