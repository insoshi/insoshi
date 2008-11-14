require 'rake'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/rdoctask'
require 'find'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test ActiveScaffold.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for ActiveScaffold.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ActiveScaffold'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
