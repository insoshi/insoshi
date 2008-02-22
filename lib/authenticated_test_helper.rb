module AuthenticatedTestHelper
  # Sets the current person in the session from the person fixtures.
  # Returns the person to allow @person = login_as(:quentin) construction.
  def login_as(person)
    if person.is_a?(Person)
      id = person.id
    elsif person.is_a?(Symbol)
      person = people(person)
      id = person.id
    elsif person.nil?
      id = nil
    end
    @request.session[:person_id] = id
    # Stub out the controller if it's defined.
    if defined?(controller)
      controller.stub!(:current_person).and_return(person)
    end
    person
  end

  def logout
    @request.session[:person_id] = nil
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end
end
