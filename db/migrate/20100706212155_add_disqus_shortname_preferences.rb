class AddDisqusShortnamePreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :disqus_shortname, :string
  end

  def self.down
    remove_column :preferences, :disqus_shortname
  end
end
