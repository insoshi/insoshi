class AddWebSiteUrlToProfile < ActiveRecord::Migration
  def self.up
    add_column :people, :web_site_url, :string
  end

  def self.down
    remove_column :people, :web_site_url
  end
end
