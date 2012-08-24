#!/usr/bin/ruby

source :rubygems

gem 'rails', '3.1.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem "unicorn"
gem "newrelic_rpm"
gem "girl_friday"

group :assets do
  gem "sass-rails", '3.1.5'
  gem "uglifier"
  gem 'jquery-ui-rails'
end

gem "audited-activerecord"

gem 'jquery-rails'

#gem "rack", '= 1.2.2'   #Heroku seems to force this
gem 'dynamic_form'
gem "oauth"
gem "chronic"

gem "feed-normalizer"
gem "texticle", "1.0.4.20101004123327"

gem "aws-s3"
gem "rmagick", :require => 'RMagick'
gem "rack-openid"
gem "heroku"
gem "json"
gem "therubyracer"

gem "will_paginate", "~> 3.0.pre2"
gem "aasm"
gem "authlogic"
#gem "authlogic-oid", :require => "authlogic_openid"
gem "ruby-openid", :require => "openid"
gem "oauth-plugin", :path => "#{File.expand_path(__FILE__)}/../vendor/gems/oauth-plugin-0.4.0.pre7"
gem "cancan"
gem "dalli"
gem "redcarpet", "1.17.2"
gem 'rails_admin'
gem "ar_after_transaction"

group :development, :test do
  gem 'sqlite3'
  gem "silent-postgres"
  gem "rack"
  gem "rack-test"
  gem "awesome_print"
  gem "artifice"
  gem "opentransact"
end

group :test do
  gem "capybara"
  gem "cucumber"
  gem "cucumber-rails"
  gem "database_cleaner"
  gem "guard-spork"
  gem "rspec-rails" # :lib => false unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))
  gem "spork"
  gem "test-unit"
end
