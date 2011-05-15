source :gemcutter	
gem "rails", '2.3.11'
#gem "rack", '= 1.2.2'   #Heroku seems to force this
gem "pg"
gem "oauth"
gem "chronic"

gem "feed-normalizer"
gem "texticle"

gem "eventmachine"
gem "aws-s3"
gem "rmagick"
gem "rack-openid"
gem "heroku", "1.18.2"
gem "json"


gem "aasm"
gem "authlogic"
gem "authlogic-oid", :require => "authlogic_openid"
gem "ruby-openid", :require => "openid"
gem "oauth-plugin", :path => "#{File.expand_path(__FILE__)}/../vendor/gems/oauth-plugin-0.4.0.pre4"
gem "cancan", "1.5.1"
gem "dalli"

group :development, :test do
  gem "rspec-rails", "1.3.2" # :lib => false unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))
  gem "webrat"  
  gem "cucumber"
  gem "cucumber-rails"
  gem "awesome_print"
end
