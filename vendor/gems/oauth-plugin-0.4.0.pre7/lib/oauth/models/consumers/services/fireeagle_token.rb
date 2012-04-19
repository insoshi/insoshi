require 'fireeagle'
# For more information on FireEagle
# http://fireeagle.rubyforge.org/
class FireeagleToken < ConsumerToken
  FIREEAGLE_SETTINGS={
    :site=>"https://fireeagle.yahooapis.com",
    :authorize_url=>"https://fireeagle.yahoo.net/oauth/authorize"}

  def self.consumer
    @consumer||=OAuth::Consumer.new credentials[:key],credentials[:secret],FIREEAGLE_SETTINGS
  end

  def client
    @client||=FireEagle::Client.new :consumer_key => FireeagleToken.consumer.key,
                                    :consumer_secret => FireeagleToken.consumer.secret,
                                    :access_token => token,
                                    :access_token_secret => secret
  end

  # Returns the FireEagle User object
  # http://fireeagle.rubyforge.org/classes/FireEagle/User.html
  def fireeagle_user
    @fireeagle_user||=client.user
  end

  # gives you the best guess of a location for user.
  # This returns the FireEagle Location object:
  # http://fireeagle.rubyforge.org/classes/FireEagle/Location.html
  def location
    fireeagle_user.best_guess.name
  end

  # Updates thes users location
  # see: http://fireeagle.rubyforge.org/classes/FireEagle/Client.html#M000026
  def update_location(location={})
    client.update(location)
  end
end

