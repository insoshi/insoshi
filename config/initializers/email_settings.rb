begin
  unless Rails.env.test?
    global_prefs = Preference.find(:first)
    if global_prefs.email_notifications?
      ActionMailer::Base.delivery_method = :smtp
      starttls_auto = 587==global_prefs.smtp_port ? true : false
      ActionMailer::Base.smtp_settings = {
        :address    => global_prefs.smtp_server,
	:port => global_prefs.smtp_port,
	:authentication => :plain,
        :domain     => global_prefs.domain,
        :enable_starttls_auto => starttls_auto,
	:user_name => ENV['SMTP_USER'] || ENV['GMAIL_SMTP_USER'],
	:password => ENV['SMTP_PASSWORD'] || ENV['GMAIL_SMTP_PASSWORD']
      }
      ActionMailer::Base.default_url_options[:host] = global_prefs.server_name
    end
  end

rescue
  # Rescue from the error raised upon first migrating
  # (needed to bootstrap the preferences).
  nil
end
