begin
  unless test?
    global_prefs = Preference.find(:first)
    if global_prefs.email_notifications?
      smtp_port = 'smtp.gmail.com' == global_prefs.smtp_server ? 587 : 25
      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.smtp_settings = {
        :address    => global_prefs.smtp_server,
	:port => smtp_port,
	:authentication => :plain,
        :domain     => global_prefs.domain,
#	:domain => ENV['GMAIL_SMTP_USER'],
	:user_name => ENV['GMAIL_SMTP_USER'],
	:password => ENV['GMAIL_SMTP_PASSWORD']
      }
    end
  end
rescue
  # Rescue from the error raised upon first migrating
  # (needed to bootstrap the preferences).
  nil
end
