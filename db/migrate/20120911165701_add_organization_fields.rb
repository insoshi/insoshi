class AddOrganizationFields < ActiveRecord::Migration
  def up
    create_table :business_types do |t|
      t.string :name, :null => false, :limit => 100
      t.string :description
      t.timestamps
    end

    create_table :plan_types do |t|
      t.string :name, :null => false, :limit => 100
      t.string :description
      t.timestamps
    end

    create_table :activity_statuses do |t|
      t.string :name, :null => false, :limit => 100
      t.string :description
      t.timestamps
    end

  	add_column :people, :business_name, :string
  	add_column :people, :legal_business_name, :string
  	add_column :people, :business_type_id, :integer
  	add_column :people, :title, :string
  	add_column :people, :activity_status_id, :integer
  	add_column :people, :plan_type_id, :integer
  	add_column :people, :support_contact_id, :integer
  end

  def down
  	remove_column :people, :business_name
  	remove_column :people, :legal_business_name
  	remove_column :people, :business_type_id
  	remove_column :people, :title
  	remove_column :people, :activity_status_id
  	remove_column :people, :plan_type_id
  	remove_column :people, :support_contact_id

    drop_table :business_types
    drop_table :plan_types
    drop_table :activity_statuses
  end
end
