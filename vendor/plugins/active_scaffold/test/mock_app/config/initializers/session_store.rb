# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mock_app_session',
  :secret      => 'ed0122432f6132fc5c99c928dc133a0863df7f24b0f2d53ce9dc2e9885a9b1f944d8ac6390333e2f1a72f902554bdaca75024fb23eb11a4548b0af4731439be2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
