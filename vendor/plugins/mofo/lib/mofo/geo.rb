# => http://microformats.org/wiki/geo
require 'microformat'

class Geo < Microformat
  one :latitude, :longitude
end
