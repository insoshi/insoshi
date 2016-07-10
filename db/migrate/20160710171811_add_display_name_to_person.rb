class AddDisplayNameToPerson < ActiveRecord::Migration
  def up
    add_column :people, :display_name, :string

    Person.where('1=1').each do |person|
      person.update_attribute('display_name', person.legacy_display_name)
    end
  end

  def down
    remove_column :people, :display_name
  end
end
