#
# = rand.rb -- library for picking random elements and shuffling
#
# Copyright (C) 2004  Ilmari Heikkinen
#
# Documentation:: Christian Neukirchen <mailto:chneukirchen@gmail.com>
# 


module Enumerable
  # Choose and return a random element of the Enumerable.
  #   [1, 2, 3, 4].pick  #=> 2 (or 1, 3, 4)
  def pick
    entries.pick
  end

  # Return an array of the elements in random order.
  #   [1, 2, 3, 4].shuffle  #=> [3, 4, 1, 2]
  def shuffle
    entries.shuffle
  end

  # Calls _block_ once for each element in _self_ in random order,
  # passing that element as a parameter.
  def each_random(&block)
    shuffle.each(&block)
  end

  # Invokes _block_ once for each element of _self_ in random order.
  # Creates a new array containing the values returned by the block.
  def map_random(&block)
    shuffle.map(&block)
  end
end


class Array
  # Choose and return a random element of _self_.
  #   [1, 2, 3, 4].pick  #=> 2 (or 1, 3, 4)
  def pick
    self[pick_index]
  end

  # Deletes a random element of _self_, returning that element.
  #   a = [1, 2, 3, 4]
  #   a.pick  #=> 2
  #   a       #=> [1, 3, 4]
  def pick!
    i = pick_index
    rv = self[i]
    delete_at(i)
    rv
  end

  # Return the index of an random element of _self_.
  #   ["foo", "bar", "baz"].pick_index  #=> 1 (or 0, or 2)
  def pick_index
    Kernel.rand(size)
  end

  # Destructive pick_index.  Delete a random element of _self_ and
  # return its index.
  #   a = [11, 22, 33, 44]
  #   a.pick_index!  #=> 2
  #   a              #=> [11, 22, 44]
  def pick_index!
    i = pick_index
    delete_at i
    i
  end

  # Return a random element of _self_ with its index.
  #   a = ["a", "b", "c", "d"]
  #   a.pick_with_index #=> ["b", 1]
  #   a #=> ["a", "b", "c", "d"]
  def pick_with_index
    i = pick_index
    [self[i], i]
  end

  # Delete and return a random element of _self_ with its index.
  #   a = ["a", "b", "c", "d"]
  #   a.pick_with_index! #=> ["b", 1]
  #   a #=> ["a", "c", "d"]
  def pick_with_index!
    rv = pick_with_index
    delete_at rv[1]
    rv
  end

  # Return an array of the elements in random order.
  #   [11, 22, 33, 44].shuffle  #=> [33, 11, 44, 22]
  def shuffle
    dup.shuffle!
  end

  # Destructive shuffle.  Arrange the elements of _self_ in new order.
  # Using Fisher-Yates shuffle.
  #   a = [11, 22, 33, 44]
  #   a.shuffle!
  #   a                      #=> [33, 11, 44, 22]
  def shuffle!
    (size-1).downto(1) {|index|
      other_index = Kernel.rand(index+1)
      next if index == other_index
      tmp = self[index]
      self[index] = self[other_index]
      self[other_index] = tmp
    }
    self
  end
end


class Hash
  # Choose and return a random key-value pair of _self_.
  #   {:one => 1, :two => 2, :three => 3}.pick  #=> [:one, 1]
  def pick
    k = keys.pick
    [k, self[k]]
  end

  # Deletes a random key-value pair of _self_, returning that pair.
  #   a = {:one => 1, :two => 2, :three => 3}
  #   a.pick  #=> [:two, 2]
  #   a       #=> {:one => 1, :three => 3}
  def pick!
    rv = pick
    delete rv.first
    rv
  end

  # Return a random key of _self_.
  #   {:one => 1, :two => 2, :three => 3}.pick_key  #=> :three
  def pick_key
    keys.pick
  end

  # Return a random value of _self_.
  #   {:one => 1, :two => 2, :three => 3}.pick_value  #=> 3
  def pick_value
    values.pick
  end

  # Delete a random key-value pair of _self_ and return the key.
  #   a = {:one => 1, :two => 2, :three => 3}
  #   a.pick_key!  #=> :two
  #   a       #=> {:one => 1, :three => 3}
  def pick_key!
    pick!.first
  end

  # Delete a random key-value pair of _self_ and return the value.
  #   a = {:one => 1, :two => 2, :three => 3}
  #   a.pick_value!  #=> 2
  #   a       #=> {:one => 1, :three => 3}
  def pick_value!
    pick!.last
  end

  # Return the key-value pairs of _self_ with _keys_ and _values_
  # shuffled independedly.
  #   {:one => 1, :two => 2, :three => 3}.shuffle_hash_pairs
  #      #=> [[:one, 3], [:two, 1], [:three, 2]]
  def shuffle_hash_pairs
    keys.shuffle.zip(values.shuffle)
  end

  # Return a copy of _self_ with _values_ arranged in random order.
  #   {:one => 1, :two => 2, :three => 3}.shuffle_hash
  #      #=> {:two=>2, :three=>1, :one=>3}
  def shuffle_hash
    shuffled = {}
    shuffle_hash_pairs.each{|k, v|
      shuffled[k] = v
    }
    shuffled
  end

  # Destructive shuffle_hash.  Arrange the values of _self_ in
  # new, random order.
  #   h = {:one => 1, :two => 2, :three => 3}
  #   h.shuffle_hash!
  #   h  #=> {:two=>2, :three=>1, :one=>3}
  def shuffle_hash!
    shuffle_hash_pairs.each{|k, v|
      self[k] = v
    }
    self
  end
end


class String

  # Return the string with characters arranged in random order.
  #   "Ruby rules".shuffle_chars  #=> "e lybRsuur"
  def shuffle_chars
    dup.shuffle_chars!
  end

  # Destructive shuffle_chars.  Arrange the characters of the string
  # in new, random order.
  #   s = "Ruby rules".shuffle_chars
  #   s.shuffle_chars!
  #   s    #=> "e lybRsuur"
  def shuffle_chars!
    (0...size).each {|j| 
      i = Kernel.rand(size-j)
      self[j], self[j+i] = self[j+i], self[j]
    }
    self
  end

  # Return a random byte of _self_.
  #   "Ruby rules".pick_byte  #=> 121
  def pick_byte
    self[pick_index]
  end

  # Return a single-character string of a random character in _self_.
  #   "Ruby rules".pick_char  #=> "y"
  def pick_char
    pick_byte.chr
  end

  # Destructive pick_char.  Delete a random character of the string
  # and return it as a single-character string.
  #   s = "Ruby rules"
  #   s.pick_char!  #=> "y"
  #   s             #=> "Rub rules"
  def pick_char!
    i = pick_index
    rv = self[i,1]
    self[i,1] = ""
    rv
  end

  # Destructive pick_byte.  Delete a random byte of _self_ and return it.
  #   s = "Ruby rules"
  #   s.pick_byte!  #=> 121
  #   s             #=> "Rub rules"
  def pick_byte!
    pick_char![0]
  end

  # Return a random byte index of _self_.
  #   "Ruby rules".pick_index  #=> 3
  def pick_index
    Kernel.rand(size)
  end

  # Destructive pick_index.  Delete a random byte of _self_ and
  # return it's index.
  #   s = "Ruby rules"
  #   s.pick_index  #=> 3
  #   s             #=> "Rub rules"
  def pick_index!
    i = pick_index
    self[i,1] = ""
    i
  end

  # Return a two element array consisting of an random byte of _self_
  # and it's index.
  #   "Ruby rules".pick_byte_with_index  #=> [121, 3]
  def pick_byte_with_index
    i = pick_index
    [self[i], i]
  end

  # Destructive pick_byte_with_index.  Delete a random byte of _self_
  # and return it and it's index.
  #   s = "Ruby rules"
  #   s.pick_byte_with index!  #=> [121, 3]
  #   s                        #=> "Rub rules"
  def pick_byte_with_index!
    rv = pick_byte_with_index
    delete_at(rv[0])
    rv
  end

  # Return a single-character string of a random character in _self_
  # and it's index.
  #   "Ruby rules".pick_char_with_index  #=> ["y", 3]
  def pick_char_with_index
    byte, index = pick_byte_with_index
    [byte.chr, index]
  end

  # Destructive pick_char_with_index.  Delete a random character of
  # the string and return it as a single-character string together
  # with it's index.
  #   s = "Ruby rules"
  #   s.pick_char_with_index!  #=> ["y", 3]
  #   s                        #=> "Rub rules"
  def pick_char_with_index!
    byte, index = pick_byte_with_index!
    [byte.chr, index]
  end

  def pick
    to_a.pick
  end

  def pick!
    pick_with_index![0]
  end

  def pick_with_index
    to_a.pick_with_index
  end

  def pick_with_index!
    tokens = to_a
    s, index = tokens.pick_with_index
    start = tokens[0, index].join
    self[start.size, s.size] = ""
    [s, index]
  end
end


if __FILE__ == $0

require 'test/unit'

module RandTestHelpers          # :nodoc:
  def picker(enum, enum_check, method, n=50)
    (1..n).all?{ enum_check.include? enum.send(method) }
  end

  def try_shuffling(enum, enum_c, method)
    rv = nil
    10.times{
     rv = enum.send method
     break if rv != enum_c
    }
    rv
  end
end


class RandArrayTest < Test::Unit::TestCase  # :nodoc:
  include RandTestHelpers

  def ar
    (0..99).to_a
  end

  def test_pick
    a = ar
    results = (0...a.size).map{ a.pick }
    assert true, results.all? {|r| a.include? r }
  end

  def test_pick!
    a = ar
    results = (0...a.size).map{ a.pick! }
    assert true, results.sort == (0..99).to_a and a.empty?
  end

  def test_pick_index
    a = ar
    results = (0...a.size).map{ a.pick_index }
    assert true, results.all? {|r| r.between?(0, a.size-1) }
  end

  def test_pick_index!
    a = ar
    # side-effect-relying block; a.size = a.size-1 after pick_index!,
    # so the picked index max value is the new a.size
    assert true, (0...a.size).all?{ a.pick_index!.between?(0, a.size) } and a.empty?
  end

  def test_shuffle
    a = ar
    shuffled = try_shuffling(a, a, :shuffle)
    assert true, shuffled.sort == a and shuffled != a
  end

  def test_shuffle!
    a = ar
    try_shuffling(a, ar, :shuffle!)
    assert true, a != ar and a.sort == ar
  end
end


class RandHashTest < Test::Unit::TestCase  # :nodoc:
  include RandTestHelpers

  def ha
    Hash[*(1..100).to_a]
  end

  def test_pick
    assert true, picker(ha, ha.entries, :pick)
  end

  def test_pick!
    h = ha
    assert true, picker(h, ha.entries, :pick!) and h.empty? 
  end

  def test_pick_key
    assert true, picker(ha, ha.keys, :pick_key)
  end

  def test_pick_key!
    h = ha
    assert true, picker(h, ha.keys, :pick_key!) and h.empty?
  end

  def test_pick_value
    assert true, picker(ha, ha.values, :pick_value)
  end

  def test_pick_value!
    h = ha
    assert true, picker(h, ha.values, :pick_value!) and h.empty?
  end

  def test_shuffle_hash
    h = ha
    hs = try_shuffling(ha, h, :shuffle_hash)
    assert true, hs != h and (hs.keys + hs.values).sort == (h.keys + h.values).sort
  end

  def test_shuffle_hash!
    h = ha
    hs = ha
    try_shuffling(hs, h, :shuffle_hash!)
    assert true, hs != h and (hs.keys + hs.values).sort == (h.keys + h.values).sort
  end

  def test_shuffle
    h = ha
    hs = try_shuffling(ha, h, :shuffle)
    assert true, hs != h and hs.entries.sort == h.entries.sort
  end
end


class RandStringTest < Test::Unit::TestCase  # :nodoc:
  include RandTestHelpers

  def self.pick_tests(endings)
    endings.each{|ending, compare_str_f|
      define_method("test_pick#{ending}"){
        s = str
        assert true, picker(s, instance_eval(&compare_str_f), "pick#{ending}", s.size)
      }
    }
  end

  def self.pick_tests!(endings)
    endings.each{|ending, compare_str_f|
      define_method("test_pick#{ending}!"){
        s = str
        assert true, picker(s, instance_eval(&compare_str_f), "pick#{ending}!", s.size) and s.empty?
      }
    }
  end

  def str
    (("a".."z").to_s + "\n") * 10
  end

  def test_shuffle
    s = str
    ss = try_shuffling(s, s.to_a, :shuffle)
    assert true, ss != s.to_a and ss.sort == s.to_a.sort
  end

  def test_shuffle_chars
    s = str
    ss = try_shuffling(s, s.split(//), :shuffle_chars)
    assert true, ss != s and ss.split(//).sort == s.split(//).sort
  end

  def test_shuffle_chars!
    s = str
    ss = str
    try_shuffling(ss, s.split(//), :shuffle_chars!)
    assert true, ss != s and ss.split(//).sort == s.split(//).sort
  end

  pick_tests({ ""      => lambda{str.to_a}, 
               :_char  => lambda{str.split(//)}, 
               :_byte  => lambda{str.split(//).map{|c| c[0]}}, 
               :_index => lambda{(0...str.size).to_a}
             })

  pick_tests!({ :_char  => lambda{str.split(//)}, 
                :_byte  => lambda{str.split(//).map{|c| c[0]}}, 
                :_index => lambda{(0...str.size).to_a}
              })
end


end #if
