module PreferencesHelper

  # Return the global preferences.
  def global_prefs
    @global_prefs ||= Preference.find(:first)
  end
end
