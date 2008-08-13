require 'cgi'
require 'cgi/session'
class CGI::Session::CookieStore
  # Restore session data from the cookie.
  # This method overrides the one in 
  # actionpack/lib/action_controller/session/cookie_store.rb
  # in order to handle the case of a "tampered" cookie more gracefully.
  # The issue is that changing the 'secret' in config/environment.rb
  # breaks all sessions in such a way that everyone gets an error page
  # the first time they revisit the site.  Catching the exception here
  # prevents this ugly behavior.
  # This is in a plugin so that it loads after Rails but before environment.rb.
  def restore
    @original = read_cookie
    @data = unmarshal(@original) || {}
  rescue CGI::Session::CookieStore::TamperedWithCookie
    logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log")
    logger.warn "Caught TamperedWithCookie exception on #{Time.now}"
    @data = {}
  end
end