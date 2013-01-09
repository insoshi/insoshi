Given /^a client application$/ do
  init_oscurrency
  create_client_application
end

Given /^using opentransact gem$/ do
  @using_opentransact_gem = true
end

Given /^an account holder with asset "([^"]*)"$/ do |asset|
  # Implementation detail beyond the scope of OpenTransact
  init_asset(asset)
end

Given /^the account holder is a system admin$/ do
  make_system_admin
end

Given /^the account holder is an admin for the group with asset "([^"]*)"$/ do |asset|
  make_group_admin(asset)
end

Given /^an account holder with email "([^"]*)" and asset "([^"]*)"$/ do |email, asset|
  # XXX for now, assume asset is already created
  g = Group.by_opentransact(asset)
  p = create_person(:name => email,
                    :email => email,
                    :default_group => g,
                    :password => "password")
  Membership.request(p,g,false)
end

Given /^another asset called "([^"]*)"$/ do |asset|
  add_asset(asset)
end

Given /^an access token with scope "([^"]*)"$/ do |scope|
  create_access_token(scope)
end

Given /^the scope "([^"]*)" is invalidated$/ do |scope|
  invalidate_scope(scope)
end

When /^I request transactions for "([^"]*)"$/ do |asset|
  a = OAuth::AccessToken.new(consumer,access_token_key,access_token_secret)
  transacts_path = asset.empty? ? "/transacts" : "/transacts/#{asset}" 
  Artifice.activate_with(app) do
    @transacts = JSON.parse(a.get(transacts_path + ".json").body)
  end
end

Then /^I should see her transactions for "([^"]*)"$/ do |asset|
  if @transacts.length == 2 
    @transacts.each {|t| puts "#{t['amount']}: #{t['memo']} - #{t['txn_id']}"}
  else
    puts "Error: #{@transacts['error']}" if @transacts['error']
  end
  @transacts.should have(2).items
end

Then /^I should see all transactions for "([^"]*)"$/ do |asset|
  if @transacts.length == 3
    @transacts.each {|t| puts "#{t['amount']}: #{t['memo']} - #{t['txn_id']}"}
  else
    puts "Error: #{@transacts.inspect}"
  end
  @transacts.should have(3).items
end

Then /^I should receive error message "([^"]*)"$/ do |message|
  result = @transacts.nil? ? @transact : @transacts
  result['error'].should == message
end

When /^I pay "([^"]*)" "([^"]*)" to "([^"]*)"$/ do |amount, asset_name, to|
  transacts_path = asset_name.empty? ? "http://test.com/transacts" : "http://test.com/transacts/#{asset_name}" 
  memo = "test payment"

  if @using_opentransact_gem
    client = OpenTransact::Client.new(transacts_path, :token => access_token_key, :secret => access_token_secret,
                                      :consumer_key => consumer_key, :consumer_secret => consumer_secret)
    asset = OpenTransact::Asset.new(transacts_path, :client => client)
    Artifice.activate_with(app) do
      begin
        @transact = asset.transfer(amount,to,memo)
      rescue OpenTransact::HttpException => e
        @transact = JSON.parse(e.response.body)
      end
    end
  else
    a = OAuth::AccessToken.new(consumer,access_token_key,access_token_secret)
    opts = {:amount => amount,
            :memo => memo, 
            :to => to
            }
    Artifice.activate_with(app) do
      @transact = JSON.parse(a.post(transacts_path, opts, {'Accept'=>'application/json'}).body)
    end
  end
end

Then /^I should see a new transaction with amount "([^"]*)"$/ do |amount|
  @transact['amount'].to_f.should == amount.to_f
end

