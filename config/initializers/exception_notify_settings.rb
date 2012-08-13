begin
  unless Rails.env.test?
    global_prefs = Preference.find(:first)
    if global_prefs.exception_notification?
      if global_prefs.domain?
        ExceptionNotifier.sender_address = %("Application Error" <app.error@#{global_prefs.domain}>)
      end

      if global_prefs.app_name?
        ExceptionNotifier.email_prefix = "[#{global_prefs.app_name}] "
      end

      ExceptionNotifier.exception_recipients = global_prefs.exception_notification.split
    end
  end
rescue
    # Rescue from the error raised upon first migrating
    nil
end
