class SetIdentifier < ActiveRecord::Migration
  def self.up
    # Set the identifier for the stat tracker.
    File.open("identifier", "w") do |f|
      f.write UUID.new
    end unless File.exist?("identifier")
  end

  def self.down
  end
end
