require 'active_record'
require 'active_record/fixtures'

desc "Install Insoshi"
task :install => :environment do |t|
  Rake::Task["db:schema:load"].invoke
  begin
    Rake::Task["db:full_text_index"].invoke
  rescue
    puts "An error happened while installing the full text index: #{$!}."
    puts "No worries. This is expected with SQLite" if $!.to_s =~ /SQLite3/
    puts "Resuming with installation..."
  end
  Rake::Task["db:seed"].invoke
  puts "Installation complete!"
end
