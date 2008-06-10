# => http://microformats.org/wiki/hcalendar
require 'microformat'
require 'mofo/hcard'
require 'mofo/adr'
require 'mofo/geo'

class HCalendar < Microformat
  container :vevent

  one :class, :description, :dtend, :dtstamp, :dtstart,
      :duration, :status, :summary, :uid, :last_modified, 
      :url => :url, :location => [ HCard, Adr, Geo, String ]

  many :category
end
