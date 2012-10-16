class RemoveDisqusShortnameFromPreferences < ActiveRecord::Migration
  def up
    remove_column :preferences, :disqus_shortname
  end

  def down
    add_column :preferences, :disqus_shortname, :string
  end
end
