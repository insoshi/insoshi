module OauthScope
  def self.all_exist?(scopes)
    return false unless scopes
    scopes.split.each do |scope|
      scope_uri = URI.parse(scope)
      # XXX ignoring host:port and assuming it's our host:port
      filepath = ::Rails.root.to_s + '/public' + scope_uri.path
      unless File.exist?(filepath)
        return false
      end
    end
    true
  end
end
