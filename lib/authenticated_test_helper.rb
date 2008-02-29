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
    # Stub out the controller if it's defined.
    # This means, e.g., that if a spec defines mocked-out photos for a person,
    # it current_person.photos will have the right assocation.
    if defined?(controller)
      controller.stub!(:current_person).and_return(person)
    else
      @request.session[:person_id] = id
    end
    person
  end

  def logout
    @request.session[:person_id] = nil
    if defined?(controller)
      controller.stub!(:current_person).and_return(:false)
    end
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
  end
end
