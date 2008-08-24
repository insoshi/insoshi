require 'ftools'

puts IO.read(File.join(File.dirname(__FILE__), 'README'))

dest_config_file = File.expand_path("#{File.dirname(__FILE__)}/../../../config/newrelic.yml")
src_config_file = "#{File.dirname(__FILE__)}/newrelic.yml"

unless File::exists? dest_config_file

  generated_for_user = ""
  license_key = "PASTE_YOUR_KEY_HERE"
  
  yaml = eval "%Q[#{File.read(src_config_file)}]"
  
  File.open( dest_config_file, 'w' ) do |out|
    out.puts yaml
  end
  
  puts "\nInstalling a default configuration file."
  puts "To monitor your application in production mode, you must enter a license key."
  puts "See #{dest_config_file}"
  puts "For a license key, sign up at http://rpm.newrelic.com/signup."
end  
