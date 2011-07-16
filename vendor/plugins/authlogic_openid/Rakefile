ENV['RDOCOPT'] = "-S -f html -T hanna"

require "rubygems"
require "hoe"
require File.dirname(__FILE__) << "/lib/authlogic_openid/version"

Hoe.new("Authlogic OpenID", AuthlogicOpenid::Version::STRING) do |p|
  p.name = "authlogic-oid"
  p.rubyforge_name = "authlogic-oid"
  p.author = "Ben Johnson of Binary Logic"
  p.email  = 'bjohnson@binarylogic.com'
  p.summary = "Extension of the Authlogic library to add OpenID support."
  p.description = "Extension of the Authlogic library to add OpenID support."
  p.url = "http://github.com/binarylogic/authlogic_openid"
  p.history_file = "CHANGELOG.rdoc"
  p.readme_file = "README.rdoc"
  p.extra_rdoc_files = ["CHANGELOG.rdoc", "README.rdoc"]
  p.remote_rdoc_dir = ''
  p.test_globs = ["test/*/test_*.rb", "test/*_test.rb", "test/*/*_test.rb"]
  p.extra_deps = %w(authlogic)
end