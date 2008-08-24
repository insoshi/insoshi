
if defined? Memcached

  
# Support for libmemcached through Evan Weaver's memcached wrapper
# http://blog.evanweaver.com/files/doc/fauna/memcached/classes/Memcached.html    
  
class Memcached
  add_method_tracer :get, 'Memcached/read'
  add_method_tracer :set, 'Memcached/write'
end


end