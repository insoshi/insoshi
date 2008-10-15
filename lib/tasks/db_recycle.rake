namespace :db do
  desc "Recycle the databases by dropping, recreating, and migrating"
  task :recycle => :environment  do
    system 'rake db:drop:all'
    system 'rake db:create:all'
    system 'rake db:migrate'
    system 'rake db:test:prepare'
  end
end