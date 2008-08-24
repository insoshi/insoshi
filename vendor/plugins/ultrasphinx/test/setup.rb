
# Setup integration system for the integration suite

Dir.chdir "#{File.dirname(__FILE__)}/integration/app/" do

  pid_file = '/tmp/sphinx/searchd.pid'
  if File.exist? pid_file
    pid = File.read(pid_file).to_i
    system("kill #{pid}"); sleep(2); system("kill -9 #{pid}")  
  end
  
  system("rm -rf /tmp/sphinx")  
  system("rm -rf config/ultrasphinx/development.conf")

  Dir.chdir "vendor/plugins" do
    system("rm ultrasphinx")
    system("ln -s ../../../../../ ultrasphinx")
  end
  
  if ENV['DB'] == 'postgresql'
    # http://dev.rubyonrails.org/ticket/10559
    system("echo 'DROP DATABASE ultrasphinx_development;' | psql template1") 
  else
    system("rake db:drop --trace")
  end
  
  system("rake db:create --trace")
  system("script/generate ultrasphinx_migration --svn") if ENV['DB'] == 'postgresql'
  system("rake db:migrate db:fixtures:load --trace")

  system("rake us:boot --trace")
  system("rm /tmp/ultrasphinx-stopwords.txt")
  system("rake ultrasphinx:spelling:build --trace")
end
