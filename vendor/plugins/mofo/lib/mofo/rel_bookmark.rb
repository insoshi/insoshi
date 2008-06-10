# => http://microformats.org/wiki/rel-design-pattern
require 'microformat/simple'

class RelBookmark < Microformat::Simple
  from :rel => :bookmark
end
