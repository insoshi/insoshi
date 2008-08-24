
# Tear down integration system for the integration suite

Dir.chdir "#{File.dirname(__FILE__)}/integration/app/" do  
  # Remove the symlink created by the setup method, for people with tools
  # that can't handle recursive directories (Textmate).
  system("rm vendor/plugins/ultrasphinx") unless ENV['USER'] == 'eweaver'
  
  # Remove the generated Postgres migration, if it exists
  Dir["db/migrate/*_install_ultrasphinx_stored_procedures.rb"].each do |file|
    system("svn del --force #{file}")
  end  
end