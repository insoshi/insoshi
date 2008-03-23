# Adapted from the rake Rakefile.

require "rubygems"
require "rake/testtask"
require "rake/rdoctask"
require "rake/gempackagetask"

VERSION_FILE = "lib/uuid.rb"
# Create the GEM package.
spec = Gem::Specification.new do |spec|
  spec.name = "uuid"
  spec.version = File.read(__FILE__.pathmap("%d/#{VERSION_FILE}")).scan(/VERSION\s*=\s*(['"])(.*)\1/)[0][1]
  spec.summary = "UUID generator"
  spec.description = <<-EOF
    UUID generator for producing universally unique identifiers based
    on RFC 4122 (http://www.ietf.org/rfc/rfc4122.txt).
EOF
  spec.author = "Assaf Arkin"
  spec.email = "assaf@labnotes.org"
  spec.homepage = "http://trac.labnotes.org/cgi-bin/trac.cgi/wiki/Ruby/UuidGenerator"
  spec.files = FileList["{bin,test,lib,docs}/**/*", "README", "MIT-LICENSE", "Rakefile", "CHANGELOG"].to_a
  spec.require_path = "lib"
  spec.autorequire = "uuid.rb"
  spec.bindir = "bin"
  spec.executables = ["uuid-setup"]
  spec.default_executable = "uuid-setup"
  spec.has_rdoc = true
  spec.rdoc_options << "--main" << "README" << "--title" <<  "UUID generator" << "--line-numbers"
  spec.extra_rdoc_files = ["README"]
  spec.rubyforge_project = "reliable-msg"
end


desc "Default Task"
task :default => [:test, :rdoc]


desc "Run all test cases"
Rake::TestTask.new do |test|
  test.verbose = true
  test.test_files = ["test/*.rb"]
  #test.warning = true
end

# Create the documentation.
Rake::RDocTask.new do |rdoc|
  rdoc.main = "README"
  rdoc.rdoc_files.include("README", "lib/**/*.rb")
  rdoc.title = "UUID generator"
end

gem = Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
  pkg.need_zip = true
end

desc "Install the package locally"
task :install=>:package do |task|
  system "gem", "install", "pkg/#{spec.name}-#{spec.version}.gem"
end

desc "Uninstall previously installed packaged"
task :uninstall do |task|
  system "gem", "uninstall", spec.name, "-v", spec.version.to_s
end


desc "Look for TODO and FIXME tags in the code"
task :todo do
  FileList["**/*.rb"].egrep /#.*(FIXME|TODO|TBD)/
end


# --------------------------------------------------------------------
# Creating a release


namespace :upload do
  task :packages=>["rake:rdoc", "rake:package"] do |task|
    require 'rubyforge'

    # Read the changes for this release.
    pattern = /(^(\d+\.\d+(?:\.\d+)?)\s+\(\d+\/\d+\/\d+\)\s*((:?^[^\n]+\n)*))/
    changelog = File.read(__FILE__.pathmap("%d/CHANGELOG"))
    changes = changelog.scan(pattern).inject({}) { |hash, set| hash[set[1]] = set[2] ; hash }
    current = changes[spec.version.to_s]
    if !current && spec.version.to_s =~ /\.0$/
      current = changes[spec.version.to_s.split(".")[0..-2].join(".")] 
    end
    fail "No changeset found for version #{spec.version}" unless current

    puts "Uploading #{spec.name} #{spec.version}"
    files = %w( gem tgz zip ).map { |ext| "pkg/#{spec.name}-#{spec.version}.#{ext}" }
    rubyforge = RubyForge.new
    rubyforge.login    
    File.open(".changes", 'w'){|f| f.write(current)}
    rubyforge.userconfig.merge!("release_changes" => ".changes",  "preformatted" => true)
    rubyforge.add_release spec.rubyforge_project.downcase, spec.name.downcase, spec.version, *files
    rm ".changes"
    puts "Release #{spec.version} uploaded"
  end
end

namespace :release do
  task :ready? do
    require 'highline'
    require 'highline/import'

    puts "This version: #{spec.version}"
    puts
    puts "Top 4 lines form CHANGELOG:"
    puts File.readlines("CHANGELOG")[0..3].map { |l| "  #{l}" }
    puts
    ask("Top-entry in CHANGELOG file includes today's date?") =~ /yes/i or
      fail "Please update CHANGELOG to include the right date"
  end

  task :post do
    # Practical example of functional read but not comprehend code:
    next_version = spec.version.to_ints.zip([0, 0, 1]).map { |a| a.inject(0) { |t,i| t + i } }.join(".")
    puts "Updating #{VERSION_FILE} to next version number: #{next_version}"
    ver_file = File.read(__FILE__.pathmap("%d/#{VERSION_FILE}")).
      sub(/(VERSION\s*=\s*)(['"])(.*)\2/) { |line| "#{$1}#{$2}#{next_version}#{$2}" } 
    File.open(__FILE__.pathmap("%d/#{VERSION_FILE}"), "w") { |file| file.write ver_file }
    puts "Adding entry to CHANGELOG"
    changelog = File.read(__FILE__.pathmap("%d/CHANGELOG"))
    File.open(__FILE__.pathmap("%d/CHANGELOG"), "w") { |file| file.write "#{next_version} (Pending)\n\n#{changelog}" }
  end

  task :meat=>["clobber", "test", "upload:packages"]
end

desc "Upload release to RubyForge including docs, tag SVN"
task :release=>[ "release:ready?", "release:meat", "release:post" ]

=begin

# Handle version number.
class Version

  PATTERN = /(\s*)VERSION.*(\d+\.\d+\.\d+)/

  def initialize file, new_version
    @file = file
    @version = File.open @file, "r" do |file|
      version = nil
      file.each_line do |line|
        match = line.match PATTERN
        if match
          version = match[2]
          break
        end
      end
      version
    end
    fail "Can't determine version number" unless @version
    @new_version = new_version || @version
  end

  def changed?
    @version != @new_version
  end

  def number
    @version
  end

  def next
    @new_version
  end

  def update
    puts "Updating to version #{@new_version}"
    copy = "#{@file}.new"
    open @file, "r" do |input|
      open copy, "w" do |output|
        input.each_line do |line|
          match = line.match PATTERN
          if match
            output.puts "#{match[1]}VERSION = '#{@new_version}'"
          else
            output.puts line
          end
        end
      end
    end
    mv copy, @file
    @version = @new_version
  end

end
version = Version.new "lib/uuid.rb", ENV["version"]




desc "Make a new release"
task :release => [:test, :prerelease, :clobber, :update_version, :package] do
  puts
  puts "**************************************************************"
  puts "* Release #{version.number} Complete."
  puts "* Packages ready to upload."
  puts "**************************************************************"
  puts
end

task :prerelease do
  if !version.changed? && ENV["reuse"] != version.number
    fail "Current version is #{version.number}, must specify reuse=ver to reuse existing version"
  end
end

task :update_version => [:prerelease] do
  if !version.changed?
    puts "No version change ... skipping version update"
  else
    version.update
  end
end
=end
