module PreferencesHelper

  def foobarbaz
    "dude"
  end

  # Return the global preferences.
  def preferences
    @preferences ||= Preference.find(:first)
  end
end
