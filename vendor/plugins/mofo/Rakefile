require 'rubygems'
require 'rake'
gem 'echoe', '=1.3'

version = '0.2.10'

ENV['RUBY_FLAGS'] = ""

begin
  require 'echoe'

  Echoe.new('mofo', version) do |p|
    p.rubyforge_name = 'mofo'
    p.summary = "mofo is a ruby microformat parser"
    p.description = "mofo is a ruby microformat parser"
    p.url = "http://mofo.rubyforge.org/"
    p.author = 'Chris Wanstrath'
    p.email = "chris@ozmm.org"
    p.extra_deps << ['hpricot', '>=0.4.59']
    p.test_globs = 'test/*_test.rb' 
  end

rescue LoadError => boom
  puts "You are missing a dependency required for meta-operations on this gem."
  puts "#{boom.to_s.capitalize}."
end

desc 'Generate RDoc documentation for mofo.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  files = ['README', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "mofo"
  rdoc.template = File.exists?(t="/Users/chris/ruby/projects/err/rock/template.rb") ? t : "/var/www/rock/template.rb"
  rdoc.rdoc_dir = 'doc' # rdoc output folder
  rdoc.options << '--inline-source'
end
