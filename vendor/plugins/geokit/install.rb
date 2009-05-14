# Display to the console the contents of the README file.
puts IO.read(File.join(File.dirname(__FILE__), 'README'))

# Append the contents of api_keys_template to the application's environment.rb file
environment_rb = File.open(File.expand_path(File.join(File.dirname(__FILE__), '../../../config/environment.rb')), "a")
environment_rb.puts IO.read(File.join(File.dirname(__FILE__), '/assets/api_keys_template'))
environment_rb.close
