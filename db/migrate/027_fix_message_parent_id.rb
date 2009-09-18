class FixMessageParentId < ActiveRecord::Migration
  def self.up
    # This converts the communications parent_id from a string to an integer.
    # Amazingly, it works as a string, which is why it took a while to
    # notice the problem.

    # postgresql cannot typecast a string into an int
    remove_column :communications, :parent_id
    add_column :communications, :parent_id, :integer
  end

  def self.down
    remove_column :communications, :parent_id
    add_column :communications, :parent_id, :string
  end
end
