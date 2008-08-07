
class UltrasphinxMigrationGenerator < Rails::Generator::Base 

  def manifest 
    record do |m| 
      m.migration_template 'migration.rb', 'db/migrate' 
    end 
  end
  
  def file_name
    "install_ultrasphinx_stored_procedures"
  end
  
end
