class ListingsMailer < ActionMailer::Base
  extend PreferencesHelper 

  helper :people
  helper :reqs

  def updates(person,reqs)
    subject    formatted_subject("Latest Requests")
    recipients person.email
    from       "New request summary <requests@#{domain}>"
    body       "reqs" => reqs,
               "person" => person,
               "preferences_note" => preferences_note(person)
  end

  private

    def domain
      @domain ||= ListingsMailer.global_prefs.domain
    end

    def server
      @server_name ||= ListingsMailer.global_prefs.server_name
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
