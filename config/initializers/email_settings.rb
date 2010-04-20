
module ActionMailer
  class Base
    def perform_delivery_smtp(mail)
      destinations = mail.destinations
      mail.ready_to_send
      sender = (mail['return-path'] && mail['return-path'].spec) || Array(mail.from).first

      smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
      smtp.enable_starttls_auto if smtp_settings[:enable_starttls_auto] && smtp.respond_to?(:enable_starttls_auto)
      smtp.start(smtp_settings[:domain], smtp_settings[:user_name], smtp_settings[:password],
                 smtp_settings[:authentication]) do |smtp|
        smtp.sendmail(mail.encoded, sender, destinations)
      end
    end
  end
end

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
