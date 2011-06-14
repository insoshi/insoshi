# see http://prettystatemachine.blogspot.com/2010/09/typeerrors-in-tojson-make-me-briefly.html
#
class Fixnum
  def to_json(options = nil)
    to_s
  end
end
