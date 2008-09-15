require 'digest/sha1'
require 'rand'
require 'will_paginate'
require 'string'
# Handle RDiscount and BlueCloth in a unified way.
begin
  require 'rdiscount'
rescue LoadError
  # Rails loads BlueCloth automatically if present.
  nil
end

# In some cases autotest interprets the initialization of the UUID generator
# as something new, and so just keeps running the tests.
# This stub here fixes the problem.
unless test?
  require 'uuid'
else
  class UUID
    def self.new
      Time.now.to_f.to_s
    end
  end
end