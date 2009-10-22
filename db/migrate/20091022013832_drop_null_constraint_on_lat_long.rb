class DropNullConstraintOnLatLong < ActiveRecord::Migration
  def self.up
    execute("ALTER TABLE addresses ALTER COLUMN latitude DROP NOT NULL")
    execute("ALTER TABLE addresses ALTER COLUMN longitude DROP NOT NULL")
  end

  def self.down
    puts "THIS WILL ERASE ALL YOUR LOCATIONS."
    execute("UPDATE addresses SET longitude = 0 WHERE longitude IS NULL")
    execute("UPDATE addresses SET latitude = 0 WHERE latitude IS NULL")
    execute("ALTER TABLE addresses ALTER COLUMN latitude SET NOT NULL")
    execute("ALTER TABLE addresses ALTER COLUMN longitude SET NOT NULL")
  end
end
