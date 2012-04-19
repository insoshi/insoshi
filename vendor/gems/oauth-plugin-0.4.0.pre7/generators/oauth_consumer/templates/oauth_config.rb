# edit this file to contain credentials for the OAuth services you support.
# each entry needs a corresponding token model.
#
# eg. :twitter => TwitterToken, :hour_feed => HourFeedToken etc.
#
# OAUTH_CREDENTIALS => {
#   :twitter => {
#     :key => "",
#     :secret => "",
#     :client => :twitter_gem, # :twitter_gem or :oauth_gem (defaults to :twitter_gem)
#     :expose => false, # expose client at /oauth_consumers/twitter/client see docs
#     :allow_login => true # Use :allow_login => true to allow user to login to account
#   },
#   :google => {
#     :key => "",
#     :secret => "",
#     :expose => false, # expose client at /oauth_consumers/google/client see docs
#     :scope => "" # see http://code.google.com/apis/gdata/faq.html#AuthScopes
#   },
#   :github => {
#     :key => "",
#     :secret => "",
#     :expose => false, # expose client at /oauth_consumers/twitter/client see docs
#
#   },
#   :facebook => {
#     :key => "",
#     :secret => "",
#     :oauth_version => 2,
#     :super_class => 'Oauth2Token' # unnecessary if you have an explicit "class FacebookToken < Oauth2Token",
#     :options => {
#       :site => "https://graph.facebook.com"
#     }
#   },
#   :agree2 => {
#     :key => "",
#     :secret => ""
#   },
#   :fireeagle => {
#     :key => "",
#     :secret => ""
#   },
#   :oauth2_server => {
#      :key => "",
#      :secret => "",
#      :oauth_version => 2
#      :options => { # OAuth::Consumer options
#        :site => "http://hourfeed.com" # Remember to add a site for a generic OAuth site
#      }
#   },
#   :hour_feed => {
#     :key => "",
#     :secret => "",
#     :options => { # OAuth::Consumer options
#       :site => "http://hourfeed.com" # Remember to add a site for a generic OAuth site
#     }
#   },
#   :nu_bux => {
#     :key => "",
#     :secret => "",
#     :super_class => "OpenTransactToken",  # if a OAuth service follows a particular standard
#                                         # with a token implementation you can set the superclass
#                                         # to use
#     :options => { # OAuth::Consumer options
#       :site => "http://nubux.heroku.com"
#     }
#   }
# }
#
OAUTH_CREDENTIALS = {
} unless defined? OAUTH_CREDENTIALS

load 'oauth/models/consumers/service_loader.rb'