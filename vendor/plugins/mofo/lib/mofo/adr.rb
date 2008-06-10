# => http://microformats.org/wiki/adr
require 'microformat'
require 'microformat/simple'

class Adr < Microformat
  one :post_office_box, :extended_address, :street_address,
      :locality, :region, :country_name, :value, :postal_code => Simple

  many :type
end
