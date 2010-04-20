class AddLanguagePeople < ActiveRecord::Migration
  def self.up
    add_column :people, :language, :string
  end

  def self.down
    remove_column :people, :language
  end
end
