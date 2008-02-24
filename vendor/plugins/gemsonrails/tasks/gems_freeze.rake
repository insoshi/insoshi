namespace :gems do
  desc "Freeze a RubyGem into this Rails application; init.rb will be loaded on startup."
  task :freeze do
		unless gem_name = ENV['GEM']
		  puts <<-eos
Parameters:
  GEM      Name of gem (required)
  VERSION  Version of gem to freeze (optional)
  ONLY     RAILS_ENVs for which the GEM will be active (optional)
  
eos
      break
    end
    
    # ONLY=development[,test] etc
    only_list = (ENV['ONLY'] || "").split(',')
    only_if_begin = only_list.size == 0 ? "" : <<-EOS
ENV['RAILS_ENV'] ||= 'development'
if %w[#{only_list.join(' ')}].include?(ENV['RAILS_ENV'])
  EOS
    only_if_end   = only_list.size == 0 ? "" : "end"
    only_if_tab   = only_list.size == 0 ? "" : "  "

    require 'rubygems'
    # RubyGems <0.9.5
    # Gem.manage_gems
    # Gem::CommandManager.new
    
    # RubyGems >=0.9.5
    require 'rubygems/command_manager'
    require 'rubygems/commands/unpack_command'
    Gem::CommandManager.instance
    
    gem = (version = ENV['VERSION']) ?
      Gem.cache.search(gem_name, "= #{version}").first :
      Gem.cache.search(gem_name).sort_by { |g| g.version }.last
    
    version ||= gem.version.version rescue nil
    
    unpack_command_class = Gem::UnpackCommand rescue nil || Gem::Commands::UnpackCommand
    unless gem && path = unpack_command_class.new.get_path(gem_name, version)
      raise "No gem #{gem_name} #{version} is installed.  Do 'gem list #{gem_name}' to see what you have available."
    end
    
    gems_dir = File.join(RAILS_ROOT, 'vendor', 'gems')
    mkdir_p gems_dir, :verbose => false if !File.exists?(gems_dir)
    
    target_dir = ENV['TO'] || File.basename(path).sub(/\.gem$/, '')
    mkdir_p "vendor/gems/#{target_dir}", :verbose => false
    
    chdir gems_dir, :verbose => false do
      mkdir_p target_dir, :verbose => false
      abs_target_dir = File.join(Dir.pwd, target_dir)
      
      (gem = Gem::Installer.new(path)).unpack(abs_target_dir)
      chdir target_dir, :verbose => false do
        if !File.exists?('init.rb')
          File.open('init.rb', 'w') do |file|
            path_options = [gem_name, gem_name.split('-').join('/')].uniq
            code = <<-eos
require_options = #{path_options.inspect}
if require_lib = require_options.find { |path|  File.directory?(File.join(File.dirname(__FILE__), 'lib', path)) }
  require File.join(File.dirname(__FILE__), 'lib', require_lib)
else
  puts msg = "ERROR: Please update \#{File.expand_path __FILE__} with the require path for linked RubyGem #{gem_name}"
  exit
end
            eos
            tabbed_code = code.split("\n").map { |line| line = "#{only_if_tab}#{line}" }.join("\n")

            file << <<-eos
#{only_if_begin}
#{tabbed_code}
#{only_if_end}
            eos
          end
        end
      end
      puts "Unpacked #{gem_name} #{version} to '#{target_dir}'"
    end
  end

end
