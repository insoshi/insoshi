require 'active_record'
require 'active_record/fixtures'

desc "Install Insoshi"
task :install => :environment do |t|
  Rake::Task["db:migrate"].invoke
  Preference.create!(:app_name => ENV['APP_NAME'], :domain => ENV['DOMAIN'], :server_name => ENV['SERVER_NAME'], :smtp_server => ENV['SMTP_SERVER']) 
end
