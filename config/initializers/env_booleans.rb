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