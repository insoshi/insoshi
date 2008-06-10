# => http://microformats.org/wiki/hcard
require 'microformat'
require 'mofo/geo'
require 'mofo/adr'

class HCard < Microformat
  container :vcard

  one :fn, :bday, :tz, :sort_string, :uid, :class,
      :geo => Geo

  many :label, :sound, :title, :role, :key, 
       :mailer, :rev, :nickname, :category, :note,
       :logo => :url, :url => :url, :photo => :url,
       :adr => Adr

  one :n do
    one :family_name, :given_name, :additional_name
    many :honorific_prefix, :honorific_suffix
  end 

  many :email do 
    many :type
    many :value
  end 

  many :tel do
    many :type
    many :value
  end

  many :org do
    one :organization_name, :organization_unit
  end
end
