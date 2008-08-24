# = Spec, with Ultrasphinx
# Based on test_with_ultrasphinx from
# http://stephencelis.com/archive/2008/4/testing-with-ultrasphinx
#
# See [Ultrasphinx](http://blog.evanweaver.com/files/doc/fauna/ultrasphinx).
#
# This Rake task automates Ultrasphinx in a testing environment. It will start
# or set up Sphinx on your test environment if needed, run your tests, and
# restore the state of Sphinx to what is was prior to running the task, with
# exceptions. E.g.,
#
#   +rake spec_with_ultrasphinx INDEX=true PERSIST=true+.
#
# Optional variables include +SPHINX+, +INDEX+, and +PERSIST+.
#
# - +SPHINX=false+ will override Ultrasphinx when running +rake+
#   (alternatively, run +rake:test+);
# - +INDEX=true+ automatically indexes fixtures before running the tests; and
# - +PERSIST=true+ will keep Sphinx running on the test index.
#
# Your test environment must be named 'test'. The code is verbose to ensure
# [Sake](http://errtheblog.com/posts/60-sake-bomb) compatibility and a minimum
# of superfluous tasks.
task :spec_with_ultrasphinx do
  begin
    processes = case RUBY_PLATFORM
    when /djgpp|(cyg|ms|bcc)win|mingw/ then 'tasklist /v'
    when /solaris/                     then 'ps -ef'
    else;                                   'ps aux' end
    unless ENV['SPHINX'] == 'false'
      puts 'Testing with ultrasphinx...'
      environments = Dir.glob "#{RAILS_ROOT}/config/environments/*.rb"
      environments.map! { |path| path.split('/').last.split('.').first }
      `#{processes}` =~ /searchd.*(#{environments.join('|')})/
      ultrasphinx_conf = $1
      if !['test', nil].include? ultrasphinx_conf or ENV['INDEX'] == 'true'
        puts "Stopping #{ultrasphinx_conf} daemon..."
        puts `rake ultrasphinx:daemon:stop RAILS_ENV=#{ultrasphinx_conf}`
      end
      unless File.exist? "#{RAILS_ROOT}/config/ultrasphinx/test.conf"
        puts 'Bootstrapping test environment...'
        puts `rake ultrasphinx:bootstrap RAILS_ENV=test`
      end
      if ENV['INDEX'] == 'true'
        puts 'Indexing fixtures...'
        puts `rake ultrasphinx:index RAILS_ENV=test`
      end
      unless `#{processes}`.include? 'searchd'
        puts 'Starting test daemon...'
        puts `rake ultrasphinx:daemon:start RAILS_ENV=test`
      end
    end
    Rake::Task[:spec].invoke
  ensure
    unless ENV['SPHINX'] == 'false'
      if ultrasphinx_conf == 'test' or ENV['PERSIST'] == 'true'
        puts 'Daemon persisting on test index.'
      else
        puts 'Stopping test daemon...'
        puts `rake ultrasphinx:daemon:stop RAILS_ENV=test`
        unless ultrasphinx_conf.nil?
          puts "Starting #{ultrasphinx_conf} daemon..."
          puts `rake ultrasphinx:daemon:start RAILS_ENV=#{ultrasphinx_conf}`
        end
      end
    end
  end
end

# The following deletes the Rails default +rake+ call to task +test+ to
# override it with +spec_with_ultrasphinx+. E.g.,
#
#   +rake+, or +rake INDEX=true+.
Rake.application.instance_eval { @tasks.delete 'default' }
task :default => :spec_with_ultrasphinx

