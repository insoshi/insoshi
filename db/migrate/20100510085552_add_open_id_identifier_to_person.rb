class AddOpenIdIdentifierToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :openid_identifier, :string
  end

  def self.down
    remove_column :people, :openid_identifier
  end
end
