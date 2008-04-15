module PreferencesHelper

  # Return the global preferences.
  def preferences
    @preferences ||= Preference.find(:first)
  end
end
