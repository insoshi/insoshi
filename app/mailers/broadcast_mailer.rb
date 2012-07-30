class BroadcastMailer < ActionMailer::Base
  extend PreferencesHelper 
  
  def spew(person, subject, message, sent_at = Time.now)
    @message = message
    @person = person
    @preferences_note = preferences_note(person)

    mail(:to => person.email,
         :from => "Community Exchange Notes <notes@#{domain}>",
         :subject => formatted_subject(subject)
        )
  end

private

    def domain
      @domain ||= BroadcastMailer.global_prefs.domain
    end

    def server
      @server_name ||= BroadcastMailer.global_prefs.server_name
    end

    # Prepend the application name to subjects if present in preferences.
    def formatted_subject(text)
      name = PersonMailer.global_prefs.app_name
      label = name.blank? ? "" : "[#{name}] "
      "#{label}#{text}"
    end

    def preferences_note(person)
      %(To change your email notification preferences, visit
      
http://#{server}/people/#{person.to_param}/edit)
    end
end
