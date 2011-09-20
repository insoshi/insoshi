source "http://rubygems.org"

# Specify your gem's dependencies in oauth-plugin.gemspec
gemspec

require 'rbconfig'

platforms :ruby do
  if Config::CONFIG['target_os'] =~ /darwin/i
    gem 'rb-fsevent'
    gem 'growl'
  end
  if Config::CONFIG['target_os'] =~ /linux/i
    gem 'rb-inotify', '>= 0.5.1'
    gem 'libnotify',  '~> 0.1.3'
  end
end

platforms :jruby do
  if Config::CONFIG['target_os'] =~ /darwin/i
    gem 'growl'
  end
  if Config::CONFIG['target_os'] =~ /linux/i
    gem 'rb-inotify', '>= 0.5.1'
    gem 'libnotify',  '~> 0.1.3'
  end
end
