module OscurrencyHelpers
  def init_oscurrency
    Preference.create
    p = create_person
    p.default_group = create_default_group(p)
    p.save!

    visit login_url
    fill_in "person_session_email", :with => "quire@example.com"
    fill_in "person_session_password", :with => "quire"
    click_button "Sign In"
  end

  def create_default_group(person)
    valid_attributes = {
      :name => "value for name",
      :description => "value for description",
      :mode => Group::PUBLIC,
      :unit => "value for unit",
      :owner => person,
      :adhoc_currency => false
    }
    g = Group.create!(valid_attributes)
  end

  def create_person(options = {})
    record = Person.new({ :email => 'quire@example.com',
                          :password => 'quire',
                          :password_confirmation => 'quire',
                          :name => 'Quire',
                          :accept_agreement => true,
                          :description => 'A new person' }.merge(options))
    record.valid?
    record.save!
    record
  end
end

World(OscurrencyHelpers)
