
# Methods in this file need to be loaded first.
# This is because other initializers may depend on them.
# The funky filename?  Rails loads the initializers in alphabetical order.

def development?
  env_is('development')
end

def production?
  env_is('production')
end

def test?
  env_is('test')
end

def env_is(env)
  ENV['RAILS_ENV'] == env
end