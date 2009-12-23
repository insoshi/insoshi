begin
  unless test?
    global_prefs = Preference.find(:first)
    GeoKit::Geocoders::google = global_prefs.googlemap_api_key
  end
rescue
  nil
end
