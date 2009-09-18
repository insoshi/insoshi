# Load modules and classes needed to automatically mix in ActiveRecord and 
# ActionController helpers.  All other functionality must be explicitly 
# required.
require 'geo_kit/defaults'
require 'geo_kit/mappable'
require 'geo_kit/acts_as_mappable'
require 'geo_kit/ip_geocode_lookup'

# Automatically mix in distance finder support into ActiveRecord classes.
ActiveRecord::Base.send :include, GeoKit::ActsAsMappable

# Automatically mix in ip geocoding helpers into ActionController classes.
ActionController::Base.send :include, GeoKit::IpGeocodeLookup
