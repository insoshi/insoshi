begin
  unless Rails.env.test?
    global_prefs = Preference.first
    if global_prefs.email_notifications?
      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.smtp_settings = {
        :address        => 'smtp.sendgrid.net',
        :port           => '587',
        :authentication => :plain,
        :user_name      => ENV['SENDGRID_USERNAME'],
        :password       => ENV['SENDGRID_PASSWORD'],
        :domain         => 'heroku.com'
      }
      ActionMailer::Base.default_url_options[:host] = global_prefs.server_name
    end
  end

rescue
  # Rescue from the error raised upon first migrating
  # (needed to bootstrap the preferences).
  nil
end
