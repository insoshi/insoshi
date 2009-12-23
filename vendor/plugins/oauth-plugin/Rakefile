require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the oauth plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the oauth plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Oauth'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "oauth-plugin"
    gemspec.summary = "Ruby on Rails Plugin for OAuth Provider and Consumer"
    gemspec.description = "Rails plugin for implementing an OAuth Provider or Consumer"
    gemspec.email = "oauth-ruby@googlegroups.com"
    gemspec.homepage = "http://github.com/pelle/oauth-plugin/tree/master"
    gemspec.authors = ["Pelle Braendgaard"]
    gemspec.add_dependency('oauth', '>= 0.3.5')
    gemspec.rubyforge_project = 'oauth'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end