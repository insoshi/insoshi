# Rescue from the error raised upon first migrating.
begin
  unless test?
    global_prefs = Preference.find(:first)
    if global_prefs.email_notifications?
      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.smtp_settings = {
        :address    => global_prefs.smtp_server,
        :port       => 25,
        :domain     => global_prefs.email_domain
      }
    end
  end
rescue
  nil
end