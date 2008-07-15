
class InstallUltrasphinxStoredProcedures < ActiveRecord::Migration
  def self.up
    Dir.chdir("#{RAILS_ROOT}/vendor/plugins/ultrasphinx/lib/ultrasphinx/postgresql") do
      # Create the plpgsql language
      execute "CREATE LANGUAGE plpgsql" rescue nil
      # Create the rest of the functions
      Dir["*.sql"].each do |filename|
        execute File.read(filename)
      end
    end
  end
  
  def self.down
    execute "DROP FUNCTION hex_to_int(varchar);"
    execute "DROP FUNCTION crc32(text);"
    (3..32).each do |i|
      execute "DROP FUNCTION concat_ws(#{(['text'] * i).join(', ')})"
    end
    execute "DROP FUNCTION make_concat_ws() CASCADE;"    
    execute "DROP FUNCTION _group_concat(text,text) CASCADE;"        
    execute "DROP AGGREGATE group_concat(text);"
    execute "DROP FUNCTION unix_timestamp(timestamp without time zone);"
    execute "DROP LANGUAGE 'plpgsql';"    
  end
end
