class RunMigrationsMarker < ActiveRecord::Migration
  class << self
    
  def up
    
    begin
          
      migration_numbers.each do |migration_number|
        break if migration_number > old_migration_number
        mark_already_run_migration(migration_number) if migration_number > 0
      end
    
      drop_table old_schema_info_table_name
    
    rescue ActiveRecord::ActiveRecordError => ex
      say "Ignoring the exception: #{ ex }"
    end
    
  end

  def down
    # nothing to do
  end


private 
  
  def old_schema_info_table_name
    ActiveRecord::Base.table_name_prefix + "schema_info" + ActiveRecord::Base.table_name_suffix
  end
  
  def old_migration_number
    @old_migration_number ||= ActiveRecord::Base.connection.select_one("SELECT version FROM #{old_schema_info_table_name}")['version'].to_i rescue 0
  end
    
  def migration_numbers
    Dir["#{RAILS_ROOT}/db/migrate/[0-9]*_*.rb"].collect { |file| file[/(\d+)_[^\/]+\.rb$/][$1].to_i }.sort
  end

  def mark_already_run_migration(migration_number)
      ActiveRecord::Base.connection.execute("INSERT INTO #{ActiveRecord::Migrator.schema_info_table_name} VALUES(#{migration_number}, NOW())")
  end
  
  end
end
