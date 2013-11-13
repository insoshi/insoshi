class CreateTimeZones < ActiveRecord::Migration
  def change
    create_table :time_zones do |t|
      t.string :time_zone

      t.timestamps
    end

    TimeZone.create!(:time_zone => 'Pacific Time (US & Canada)')
  end
end
