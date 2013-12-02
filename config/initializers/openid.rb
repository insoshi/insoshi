if Rails.env.production? and ENV["MEMCACHIER_SERVERS"]
  require 'openid/store/memcache'
  OpenIdAuthentication.store = OpenID::Store::Memcache.new(Dalli::Client.new(ENV['MEMCACHIER_SERVERS'],
                               username: ENV['MEMCACHIER_USERNAME'],
                               password: ENV['MEMCACHIER_PASSWORD']))
end
