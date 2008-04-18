module ActiveRecord
class Migrator
    
  def self.migrate(migrations_path, target_version = nil)
      
    ActiveRecord::Base.connection.initialize_schema_information

    if target_version.nil? || (current_version <= target_version)
      up(migrations_path, target_version)
    else
      down(migrations_path, target_version)
    end

  end
  
  def self.current_version
    ActiveRecord::Base.connection.select_one("SELECT MAX(id) as max FROM #{schema_info_table_name}")["max"].to_i rescue 0
  end
  
  def self.schema_info_table_name
    ActiveRecord::Base.table_name_prefix + "migrations_info" + ActiveRecord::Base.table_name_suffix
  end
  
  
  private

  def already_migrated?(version)
    ActiveRecord::Base.connection.select_one("SELECT id FROM #{self.class.schema_info_table_name} WHERE id = #{version}") != nil
  end

  def set_schema_version(version)
    if down?
      ActiveRecord::Base.connection.execute("DELETE FROM #{self.class.schema_info_table_name} WHERE id = #{version}")
    else
      ActiveRecord::Base.connection.execute("INSERT INTO #{self.class.schema_info_table_name} VALUES(#{version}, NOW())")
    end
  end

  def irrelevant_migration?(version)
    (up? && already_migrated?(version)) || (down? && (not already_migrated?(version)))
  end

end
end


### Fixing all places where schema_info was used

ActiveRecord::ConnectionAdapters::SchemaStatements.send(:define_method, :initialize_schema_information) do
  begin
    ActiveRecord::Base.connection.execute "CREATE TABLE #{ActiveRecord::Migrator.schema_info_table_name} (id #{type_to_sql(:integer)}, created_at #{type_to_sql(:datetime)}, PRIMARY KEY (id))"
  rescue ActiveRecord::StatementInvalid
    # Migrations schema has been intialized
  end
end
ActiveRecord::ConnectionAdapters::SchemaStatements.send(:public, :initialize_schema_information)


ActiveRecord::ConnectionAdapters::SchemaStatements.send(:define_method, :dump_schema_information) do
  begin
    if (current_schema = ActiveRecord::Migrator.current_version) > 0
      return "INSERT INTO #{ActiveRecord::Migrator.schema_info_table_name} VALUES (#{current_schema}, NOW())" 
    end
  rescue ActiveRecord::StatementInvalid 
    # No Schema Info
  end
end
ActiveRecord::ConnectionAdapters::SchemaStatements.send(:public, :dump_schema_information)


ActiveRecord::SchemaDumper.send(:define_method, :initialize) do |connection|
  @connection = connection
  @types = @connection.native_database_types
  @info = {'version' => @connection.select_one("SELECT MAX(id) as max FROM migrations_info")["max"]} rescue nil
end


ActiveRecord::SchemaDumper.send(:define_method, :tables) do |stream|
  @connection.tables.sort.each do |tbl|
    next if ["migrations_info", ignore_tables].flatten.any? do |ignored|
      case ignored
      when String: tbl == ignored
      when Regexp: tbl =~ ignored
      else
        raise StandardError, 'ActiveRecord::SchemaDumper.ignore_tables accepts an array of String and / or Regexp values.'
      end
    end 
    table(tbl, stream)
  end
end

# For enhanced migrations schema define info does not do much since previous migrations are applied regardless of the current version
module ActiveRecord
  class Schema < Migration

    def self.define(info={}, &block)
      instance_eval(&block)

      if info[:version]
        initialize_schema_information
        if Base.connection.select_one("SELECT id FROM #{ActiveRecord::Migrator.schema_info_table_name} WHERE id = #{info[:version]}") == nil
          Base.connection.execute("INSERT INTO #{ActiveRecord::Migrator.schema_info_table_name} VALUES(#{info[:version]}, NOW())")
        end
      end
    end

  end
end
  
require 'rails_generator/base'
require 'rails_generator/commands'
Rails::Generator::Commands::Base.send(:define_method, :next_migration_number) do
  Time.now.utc.to_i.to_s
end
