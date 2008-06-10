# => http://microformats.org/wiki/rel-design-pattern
require 'microformat/simple'

class RelTag < Microformat::Simple
  from :rel => :tag
end
