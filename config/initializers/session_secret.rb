

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  secret = ''
begin
  secret = LocalEncryptionKey.find(:first).session_secret
rescue
  # rescue from error on first migration
  nil
end
  ActionController::Base.session = {
    :session_key => '_instant_social_session',
    :secret      => secret
  }


