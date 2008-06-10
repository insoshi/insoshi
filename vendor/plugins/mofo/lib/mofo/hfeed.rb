# => http://microformats.org/wiki/hatom
require 'mofo/hentry'

class HFeed < Microformat
  many :hentry => HEntry
end
