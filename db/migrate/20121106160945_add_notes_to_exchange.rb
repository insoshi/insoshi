class AddNotesToExchange < ActiveRecord::Migration
  def change
    add_column :exchanges, :notes, :string, :limit => 255
  end
end
