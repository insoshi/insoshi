# => http://microformats.org/wiki/hresume
require 'microformat'
require 'mofo/hcard'
require 'mofo/hcalendar'
require 'mofo/rel_tag'

class HResume < Microformat
  container :hresume

  one :summary, :contact => HCard

 # TODO: linkedin uses a comma delimited skills list rather than the rel tags in the spec
  many :skills

  many :affiliation => HCard, :education => HCalendar,
       :experience  => HCalendar
end
