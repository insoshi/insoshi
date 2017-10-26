#!/usr/bin/ruby

source 'https://rubygems.org'

ruby "2.1.5"

gem 'rails', '3.2.16'

# Database
gem 'pg'
gem "unicorn"
gem "girl_friday"
gem "exception_notification"
gem "will_paginate"
gem "draper"

gem "coffee-rails"
gem "audited-activerecord"
gem "rails3_acts_as_paranoid"
gem "acts_as_tree_rails3"
gem "uuid"

# Client side - asset management
gem 'bower-rails'

# Forms
gem 'remotipart'
gem 'dynamic_form'
gem "bootstrap_form", "~> 0.3.2"

# Authentication / Authorization
gem "cancan"
gem "oauth"
gem "authlogic"
gem "ruby-openid", :require => "openid"
gem "oauth-plugin", :path => "#{File.expand_path(__FILE__)}/../vendor/gems/oauth-plugin-0.4.0.pre7"
gem "open_id_authentication", :git => "git://github.com/rewritten/open_id_authentication.git"

# Sates
gem "aasm"

# File management and Cloud storage
gem "aws-s3"
gem "fog", '1.19.0'
gem "carrierwave"
gem "json", '~> 1.8.1'

# Image manipulation
gem "rmagick", '~> 2.15.4'
gem "mini_magick"

gem "geokit-rails3"

gem "dalli"
gem "redcarpet"
gem 'rails_admin'
gem "ar_after_transaction"
gem 'valid_email', :require => 'valid_email/email_validator'
gem "calendar_helper"
gem "gibbon", :git => "git://github.com/amro/gibbon.git"
gem "mustache"

# Payment
gem "stripe", '~> 1.10.1'

# Client side assets
gem 'bootstrap-wysihtml5-rails', '0.3.1.24'
gem 'select2-rails'

gem "feed-normalizer"
gem "texticle"

group :assets do
  gem "sass-rails"
  gem "uglifier"
end

group :development, :test do
  gem "heroku-api", "= 0.3.18"
  gem 'sqlite3'
  gem "rack"
  gem "rack-test"
  gem "awesome_print"
  gem "artifice"
  gem "opentransact"
  gem 'annotate'
  gem 'therubyracer'
end

group :debug do
  gem 'pry'
  # gem 'debugger'
end

group :development do
  gem 'xray-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'highline'
  gem 'git'
  gem 'pry-rails'

  # Developer tools
  gem 'ghi'
  gem 'letter_opener'
end

group :production do
  gem 'memcachier'
end

group :test do
  gem "rspec-rails", "~> 2.14"
  gem "capybara"
  gem "cucumber"
  gem "cucumber-rails"
  gem "database_cleaner"
  gem "guard-spork"
  gem "spork"
  gem 'stripe-ruby-mock','~> 1.10.1.6'
end


