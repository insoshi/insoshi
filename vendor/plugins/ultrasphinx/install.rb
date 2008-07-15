#!/usr/bin/env ruby

Dir.chdir("#{File.dirname(__FILE__)}/../../..") do
  require 'config/environment'
  if ActiveRecord::Base.connection.instance_variable_get('@config')[:adapter] == 'postgresql'    
    puts "Installing PostgreSQL stored procedures"
    with_svn = File.exist?(".svn") ? "--svn" : ""
    exec "script/generate ultrasphinx_migration #{with_svn}"
  end
end
