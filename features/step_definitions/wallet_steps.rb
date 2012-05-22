Given /^an access token$/ do
  create_access_token("http://example.com/scopes/all_access.json")
end

When /^I request my wallet$/ do
  a = OAuth::AccessToken.new(consumer,access_token_key,access_token_secret)
  wallet_path = "/wallet"
  Artifice.activate_with(app) do
    @wallet = JSON.parse(a.get(wallet_path + ".json").body)
  end
end

Then /^I should see "([^"]*)" in my wallet$/ do |asset|
  @assets = @wallet['assets'].map {|a| a['name']}
  @assets.each {|a| puts a}
  @assets.should include asset
end

