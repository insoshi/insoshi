Given /^a category named Vegetables\:Beans$/ do
  init_oscurrency
  sign_in_to_oscurrency

  @vegetables_category = Category.create!(:name => "Vegetables")
  @beans_category = Category.new(:name => "Beans")
  @beans_category.parent = @vegetables_category
  @beans_category.save!
end

When /^I create an offer Green Beans in the Vegetables\:Beans category$/ do
  #visit offers_path
  #click_button "add offer" XXX this button has javascript so webrat won't find it
  visit new_offer_path
  fill_in "offer_name", :with => "Green Beans"
  fill_in "offer_expiration_date", :with => DateTime.now + 1.day
  select "Vegetables:Beans", :from => "offer_category_ids"
  click_button "Create"
end

Then /^Green Beans should be in the Vegetables category$/ do
  visit categories_path
  click_link "Beans"
  response.should contain("Green Beans")
end

Given /^an offer with a price of 5$/ do
  init_oscurrency
  sign_in_to_oscurrency

  @offer = Offer.new(:name => "Pizza", :price => 5)
  @offer.person = Person.find_by_name('Quire')
  @offer.save!
end

When /^I make a payment for the offer$/ do
  visit offers_path
  click_link "Pizza"
  click_link "Accept Offer"
end

Then /^my account balance should decrease by 5$/ do
  pending
end

Then /^the provider balance should increase by 5$/ do
  pending
end

