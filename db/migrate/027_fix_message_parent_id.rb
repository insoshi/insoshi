class FixMessageParentId < ActiveRecord::Migration
  def self.up
    # This converts the communications parent_id from a string to an integer.
    # Amazingly, it works as a string, which is why it took a while to
    # notice the problem.  Even more amazingly, this conversion works
    # even for an existing database; it's smart enough to preserve the
    # information by converting the strings to ints.
    change_column :communications, :parent_id, :integer
  end

  def self.down
    change_column :communications, :parent_id, :string
  end
end
