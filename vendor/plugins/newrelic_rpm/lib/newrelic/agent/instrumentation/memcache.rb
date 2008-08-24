
if defined? MemCache

# NOTE there are multiple implementations of the MemCache client in Ruby,
# each with slightly different API's and semantics.  
# Currently we only cover memcache-client.  Need to cover Ruby-MemCache.
# See:
#     http://www.deveiate.org/code/Ruby-MemCache/ (Gem: Ruby-MemCache)
#     http://dev.robotcoop.com/Libraries/memcache-client/ (Gem: memcache-client)
class MemCache
  
  add_method_tracer :get, 'MemCache/read'  
  add_method_tracer :set, 'MemCache/write'
  
  add_method_tracer :get_multi, 'MemCache/read'
end

end