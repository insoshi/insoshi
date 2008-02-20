namespace :db do
  namespace :migrate do
    desc "Migrate and prepare test database"
    task :both do
      Rake::Task["db:migrate"].invoke
      Rake::Task["db:test:prepare"].invoke
    end
  end
end