class RequestToken<OauthToken
  
  def authorize!(person)
    return false if authorized?
    self.person=person
    self.authorized_at=Time.now
    self.save
  end
  
  def exchange!
    return false unless authorized?
    RequestToken.transaction do
      access_token=AccessToken.create(:person=>person,:client_application=>client_application)
      invalidate!
      access_token
    end
  end
end
