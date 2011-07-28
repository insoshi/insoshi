Given /^a client application$/ do
  init_oscurrency
  create_client_application
end

Given /^an account holder with asset "([^"]*)"$/ do |asset|
  # Implementation detail beyond the scope of OpenTransact
  init_asset(asset)
end

Given /^another asset called "([^"]*)"$/ do |asset|
  add_asset(asset)
end

Given /^an access token for "([^"]*)"$/ do |asset|
  create_access_token(asset)
end

When /^I request transactions for "([^"]*)"$/ do |asset|
  a = OAuth::AccessToken.new(consumer,access_token_key,access_token_secret)
  transacts_path = asset.empty? ? "/transacts" : "/transacts/#{asset}" 
  Artifice.activate_with(app) do
    @transacts = JSON.parse(a.get(transacts_path + ".json").body)
  end
end

Then /^I should see transactions for "([^"]*)"$/ do |asset|
  #@transacts.each {|t| puts "#{t['amount']}: #{t['memo']} - #{t['txn_id']}"} 
  @transacts.should have(2).items
end

Then /^I should receive error message "([^"]*)"$/ do |message|
  @transacts['error'].should == message
end

