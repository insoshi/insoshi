#!/usr/bin/ruby

source 'https://rubygems.org'
ruby "1.9.3"
gem 'rails', '3.2.16'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem "unicorn"
gem "girl_friday"
gem "exception_notification", :git => "https://github.com/smartinez87/exception_notification.git"

group :assets do
  gem "sass-rails"
  gem "uglifier"
  # gem 'jquery-ui-rails'
end

group :debug do
  gem 'debugger'
end

gem "coffee-rails"
gem "audited-activerecord"
gem "rails3_acts_as_paranoid"
gem "acts_as_tree_rails3"
gem "uuid"

# gem 'jquery-rails'

#gem "rack", '= 1.2.2'   #Heroku seems to force this
gem 'dynamic_form'
gem "oauth"

gem "feed-normalizer"
gem "texticle"

gem "aws-s3"
gem "fog"
gem "carrierwave"
gem "rmagick", :require => 'RMagick'
gem "json", '1.7.7'
gem "geokit-rails3"

gem "will_paginate"
gem "aasm"
gem "authlogic"
#gem "authlogic-oid", :require => "authlogic_openid"
gem "ruby-openid", :require => "openid"
gem "oauth-plugin", :path => "#{File.expand_path(__FILE__)}/../vendor/gems/oauth-plugin-0.4.0.pre7"
gem "open_id_authentication", :git => "git://github.com/rewritten/open_id_authentication.git"
gem "cancan"
gem "dalli"
gem "redcarpet"
gem 'rails_admin'
gem "ar_after_transaction"
gem 'valid_email', :require => 'valid_email/email_validator'
gem "calendar_helper"
gem "gibbon", :git => "git://github.com/amro/gibbon.git"
gem "bootstrap_form", "~> 0.3.2"

group :development, :test do
  gem "heroku-api"
  gem 'sqlite3'
  gem "rack"
  gem "rack-test"
  gem "awesome_print"
  gem "artifice"
  gem "opentransact"
  gem 'annotate'
  gem 'therubyracer'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'highline'
  gem 'git'
end

group :production do
  gem 'memcachier'
end

group :test do
  gem "capybara"
  gem "cucumber"
  gem "cucumber-rails"
  gem "database_cleaner"
  gem "guard-spork"
  gem "rspec-rails" # :lib => false unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))
  gem "spork"
end
gem 'remotipart'

