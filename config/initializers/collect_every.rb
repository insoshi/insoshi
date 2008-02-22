# ---------------------------------------------------------------------------
# collect_every(n [,fill=false[,offset=0]])                  => an array
# collect_every(n [,fill=false[,offset=0]]) {|item| block}   => an_array
# ---------------------------------------------------------------------------
# If a block is given, it invokes the block passing in an array of n elements.
# The last array passed may not contain n elements if size % 2 does not equal
# zero. If no block is given, it returns an array containing the collections.
#
# If the optional argument fill is set to true, the empty spaces will be
# filled with nils. The optional argument offset allows the collection to 
# start at that index in the array.
#
# a = (1..10).to_a
# a.collect_every(5)               #=> [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]]
# a.collect_every(5) {|x| p x}     #=> [1, 2, 3, 4, 5]
#                                      [6, 7, 8, 9, 10]
# b = (1..7).to_a
# b.collect_every(3)               #=> [[1, 2, 3], [4, 5, 6], [7]]
# b.collect_every(3,true)          #=> [[1, 2, 3], [4, 5, 6], [7,nil,nil]]
# b.collect_every(3,true,1)        #=> [[2, 3, 4], [5, 6, 7]]

class Array
  def collect_every(n,fill=false,offset=0)

    if block_given?
      while offset < size
        ret=[]

        if fill
          n.times do |x| 
            if offset+x > size - 1: ret << nil
            else ret << self[offset+x] end
          end
        else
          n.times { |x| ret << self[offset+x] unless offset+x > size-1 }
        end

        offset += n
        yield ret
        ret = nil
      end

    else
      ret = []
      while offset < size
        ret << []

        if fill
          n.times do |x|
            if offset+x > size - 1: ret.last << nil
            else ret.last << self[offset+x] end
          end
        else
          n.times { |x| ret.last << self[offset+x] unless offset+x > size-1 }
        end

        offset += n
      end
      return ret
    end

  end
end