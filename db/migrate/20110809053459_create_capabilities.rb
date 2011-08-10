class CreateCapabilities < ActiveRecord::Migration
  def self.up
    create_table :capabilities do |t|
      t.integer :group_id
      t.integer :oauth_token_id
      t.string  :scope
      t.timestamps
    end
  end

  def self.down
    drop_table :capabilities
  end
end
