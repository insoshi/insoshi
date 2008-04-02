class AddSomeIndices < ActiveRecord::Migration
  def self.up
    add_index :people, :admin
    add_index :people, :deactivated
    add_index :blogs, :person_id
    add_index :activities, :person_id
  end

  def self.down
    remove_index :activities, :person_id
    remove_index :blogs, :person_id
    remove_index :people, :deactivated
    remove_index :people, :admin
  end
end
