# => http://microformats.org/wiki/hreview
require 'microformat'
require 'mofo/hcard'
require 'mofo/rel_tag'

class HReview < Microformat
  one :version, :summary, :type, :dtreviewed, :rating, :description

  one :reviewer => HCard

  one :item! do
    one :fn
  end
end
