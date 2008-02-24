namespace :gems do
  desc "Unfreeze/unlink a RubyGem from this Rails application"
  task :unfreeze do
		unless gem_name = ENV['GEM']
		  puts <<-eos
Parameters:
  GEM      Name of gem (required)

  
eos
      break
		end
    Dir["vendor/gems/#{gem_name}*"].each { |d| rm_rf d }
  end
end