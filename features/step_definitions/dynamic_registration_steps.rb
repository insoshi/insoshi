Given /^a client registration endpoint$/ do
  @client_registration_endpoint = "https://example.com/oauth_clients"
end

When /^I make a client registration request$/ do
  uri = URI.parse(@client_registration_endpoint)

  Artifice.activate_with(app) do
    http = Net::HTTP.new(uri.host,uri.port)
    body = '{'
    body += '"type": "push",'
    body += '"client_name": "Online Photo Gallery",'
    body += '"client_url": "http://onlinephotogallery.com",'
    body += '"client_description": "Uploading and also editing capabilities!",'
    body += '"redirect_url": "https://onlinephotogallery.com/client_reg"'
    body += '}'

    @response = http.post(uri.path,body,{"Content-Type" => "application/json\r\n","Accept" => "application/json\r\n"})
  end
  puts @response.body
end

When /^I make a noredirect client registration request$/ do
  uri = URI.parse(@client_registration_endpoint)

  Artifice.activate_with(app) do
    http = Net::HTTP.new(uri.host,uri.port)
    body = '{'
    body += '"type": "push",'
    body += '"client_name": "Online Photo Gallery",'
    body += '"client_url": "http://onlinephotogallery.com",'
    body += '"client_description": "Uploading and also editing capabilities!",'
    body += '"application_type": "noredirect",'
    body += '"redirect_url": ""'
    body += '}'

    @response = http.post(uri.path,body,{"Content-Type" => "application/json\r\n","Accept" => "application/json\r\n"})
  end
  puts @response.body
end

Then /^I should see a new client id$/ do
  client_application = JSON.parse(@response.body)
  client_application['client_id'].should_not be_empty
end

Then /^I should see a new redirect url$/ do
  client_application = JSON.parse(@response.body)
  client_application['redirect_url'].should_not be_empty
end

When /^I exclude name from a client registration request$/ do
  uri = URI.parse(@client_registration_endpoint)

  Artifice.activate_with(app) do
    http = Net::HTTP.new(uri.host,uri.port)
    body = '{'
    body += '"type": "push",'
    #body += '"client_name": "Online Photo Gallery",'
    body += '"client_url": "http://onlinephotogallery.com",'
    body += '"client_description": "Uploading and also editing capabilities!",'
    body += '"redirect_url": "https://onlinephotogallery.com/client_reg"'
    body += '}'

    @response = http.post(uri.path,body,{"Content-Type" => "application/json\r\n","Accept" => "application/json\r\n"})
  end
  puts @response.body
end

When /^I send empty name in a client registration request$/ do
  uri = URI.parse(@client_registration_endpoint)

  Artifice.activate_with(app) do
    http = Net::HTTP.new(uri.host,uri.port)
    body = '{'
    body += '"type": "push",'
    body += '"client_name": "",'
    body += '"client_url": "http://onlinephotogallery.com",'
    body += '"client_description": "Uploading and also editing capabilities!",'
    body += '"redirect_url": "https://onlinephotogallery.com/client_reg"'
    body += '}'

    @response = http.post(uri.path,body,{"Content-Type" => "application/json\r\n","Accept" => "application/json\r\n"})
  end
  puts @response.body
end

Then /^I should see an error$/ do
  client_application = JSON.parse(@response.body)
  client_application['error'].should_not be_empty
end

