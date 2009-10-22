class DropNullConstraintOnLatLong < ActiveRecord::Migration
  def self.up
    execute("ALTER TABLE addresses ALTER COLUMN latitude DROP NOT NULL")
    execute("ALTER TABLE addresses ALTER COLUMN longitude DROP NOT NULL")
  end

  def self.down
    execute("ALTER TABLE addresses ALTER COLUMN latitude SET NOT NULL")
    execute("ALTER TABLE addresses ALTER COLUMN longitude SET NOT NULL")
  end
end
