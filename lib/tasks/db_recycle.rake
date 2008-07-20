namespace :db do
  desc "Recycle the database by dropping, recreating, and migrating"
  task :recycle => :environment  do
    filename = File.join(RAILS_ROOT, 'config', 'database.yml')
    config   = YAML::load(File.open(filename))
    database = config[ENV['RAILS_ENV']]['database']
    ActiveRecord::Base.connection.execute("DROP DATABASE #{database}")
    ActiveRecord::Base.connection.execute("CREATE DATABASE #{database}")
  end
end