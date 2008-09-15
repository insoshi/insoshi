require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'hoe'
require './lib/calendar_helper.rb'

Hoe.new('calendar_helper', CalendarHelper::VERSION) do |p|
  p.rubyforge_name = 'seattlerb'
  p.author = 'Geoffrey Grosenbach'
  p.email = 'boss AT topfunky.com'
  p.summary = 'Generates a configurable, CSS-tagged HTML calendar.'
  p.description = "A simple method to create an HTML calendar for a single month. Can be styled with CSS. Usable with Ruby on Rails."
  p.url = "http://rubyforge.org/projects/seattlerb"
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.clean_globs = ['test/output']
end

# desc "Test task (actually runs specs)"
# task "test" do
#   system "spec --format specdoc --color spec/*_spec.rb"
# end

# -- Rails-specific --

desc 'Generate documentation for the calendar_helper plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'CalendarHelper'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
