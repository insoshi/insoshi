module OpentransactHelpers
  def create_client_application
    ClientApplication.create! :name => "OpenTransact Client", :url => "http://mediaopoly.com", :person => Person.first
  end

  def consumer_key
    ClientApplication.first.key
  end

  def consumer_secret
    ClientApplication.first.secret
  end

  def consumer
    OAuth::Consumer.new(consumer_key,consumer_secret,{:site => 'http://localhost:3000'})
  end

  def create_access_token(scopes)
    # no longer associating group with access token
    a = AccessToken.create! :person => Person.find_by_email('quire@example.com'), :client_application => ClientApplication.first
    scopes.split.each do |scope|
      puts "parsing scope: #{scope}"
      a.capabilities << Capability.create!(:scope => scope)
    end
    a
  end

  def access_token_key
    AccessToken.first.token
  end

  def access_token_secret
    AccessToken.first.secret
  end
end
