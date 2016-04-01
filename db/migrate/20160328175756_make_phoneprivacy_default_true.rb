class MakePhoneprivacyDefaultTrue < ActiveRecord::Migration
  def up
    change_column_default :people, :phoneprivacy, true
  end

  def down
    change_column_default :people, :phoneprivacy, false
  end
end
