class PersonSession < Authlogic::Session::Base
  allow_http_basic_auth false 
end
