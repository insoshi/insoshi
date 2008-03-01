# Helpers added to this module are available in both controllers and views.
module SharedHelpers

  def current_person?(person)
    logged_in? and person == current_person
  end
end
