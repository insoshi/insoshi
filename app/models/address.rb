class Address < ActiveRecord::Base
  belongs_to :person
  belongs_to :state

  # XXX temp hack until geocoding feature ready
  before_create :populate_latlong

  def populate_latlong
    self.latitude = 0
    self.longitude = 0
  end
end
