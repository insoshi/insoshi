source 'http://rubygems.org'

gem 'rails', '3.1.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'

group :assets do
  gem "sass-rails"
  gem "uglifier"
end

gem 'jquery-rails'

#gem "rack", '= 1.2.2'   #Heroku seems to force this
gem 'dynamic_form'
gem "oauth"
gem "chronic"

gem "feed-normalizer"
gem "texticle", "1.0.4.20101004123327"

gem "eventmachine"
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
#gem 'rails_admin', :git => 'git://github.com/sferik/rails_admin.git', :branch => 'rails-3.0'
#gem 'rails_admin', :git => 'git://github.com/sferik/rails_admin.git', :ref =>'608ae867438f406bcd96'
gem 'rails_admin', :git => 'git://github.com/sferik/rails_admin.git'
gem "delayed_job_active_record"

group :development, :test do
  gem "silent-postgres"
  gem "test-unit"
# gem 'ruby-debug19', :require => 'ruby-debug'
  gem "rspec-rails" # :lib => false unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))
  gem "rack"
  gem "rack-test"
  gem "database_cleaner"
  gem "cucumber"
  gem "cucumber-rails"
  gem "awesome_print"
  gem "spork"
  gem "guard-spork"
  gem "artifice"
  gem "opentransact"
end
