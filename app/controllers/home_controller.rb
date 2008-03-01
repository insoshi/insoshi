class HomeController < ApplicationController
  def index
    # This is a stub for the real feed.
    @mary = Person.find_by_email("mary@michaelhartl.com")
    @michael = Person.find_by_email("michael@michaelhartl.com")
    @linda = Person.find_by_email("linda@michaelhartl.com")
  end
end
