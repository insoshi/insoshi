class AddEnableForumToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :enable_forum, :boolean, :default => true
  end
end
