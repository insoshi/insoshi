module OscurrencyHelpers
  def init_oscurrency
    Preference.create
    create_person
    visit login_url
    fill_in "email", :with => "quire@example.com"
    fill_in "password", :with => "quire"
    click_button "Sign In"
  end

  def create_person(options = {})
    record = Person.new({ :email => 'quire@example.com',
                          :password => 'quire',
                          :password_confirmation => 'quire',
                          :name => 'Quire',
                          :description => 'A new person' }.merge(options))
    record.valid?
    record.save!
    record
  end
end

World(OscurrencyHelpers)
