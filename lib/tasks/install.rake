# Provide tasks to load and delete sample user data.
require 'active_record'
require 'active_record/fixtures'

desc "Install Insoshi"
task :install => :environment do |t|
  Rake::Task["db:migrate"].invoke
  puts "Initializing global preferences"
  Preference.create!
  puts "Generating authentication keys"
  Crypto.create_keys
  puts "Writing identification key"
  File.open("identifier", "w") do |f|
    f.write UUID.new
  end unless File.exist?("identifier")
end
