module OscurrencyHelpers
  def init_oscurrency
    Preference.create!(:app_name => "APP_NAME", :domain => '', :server_name => "xyz.com", :smtp_server => '', :email_notifications => false) unless Preference.first
    q = create_person(:name => "Quire",
                      :email => "quire@example.com", 
                      :password => "quire")
  end

  def make_system_admin
    p = Person.find_by_email("patrick@example.com")
    p.admin = true
    p.save!
  end

  def make_group_admin(asset="coupons")
    p = Person.find_by_email("patrick@example.com")
    g = Group.find_by_asset(asset)
    m = Membership.mem(p,g)
    m.add_role('admin')
    m.save
  end

  def init_asset(asset="coupons")
    q = Person.find_by_email("quire@example.com")
    g = create_group("default group",q,asset)
    q.default_group = g
    q.save!
    p = create_person(:name => "Patrick",
                      :email => "patrick@example.com", 
                      :default_group => g,
                      :password => "patrick")
    # group membership required before participating in currency
    Membership.request(p,g,false)
    o = create_person(:name => "Otis",
                      :email => "otis@example.com",
                      :default_group => g,
                      :password => "otis")
    # group membership required before participating in currency
    Membership.request(o,g,false)

    2.times do
      create_exchange(q,p,g,1.0)
    end
    create_exchange(o,q,g,2.0) # adding one more in which q is not a counterparty
  end

  def add_asset(asset)
    q = Person.find_by_email("quire@example.com")
    g = create_group(asset,q,asset)
  end

  def create_exchange(customer,worker,group,amount)
    e = Exchange.new
    e.metadata = Req.create!(:name => 'Generic',:estimated_hours => 0, :group => group, :due_date => Time.now, :person => customer, :active => false)
    e.worker = worker
    e.customer = customer
    e.group = group
    e.amount = amount
    e.save!
  end

  def sign_in_to_oscurrency(email = "quire@examples.com", password = "quire")
    visit login_url
    fill_in "person_session_email", :with => email
    fill_in "person_session_password", :with => password
    click_button "Sign In"
  end

  def create_group(name,person,asset)
    valid_attributes = {
      :name => name,
      :description => "value for description",
      :mode => Group::PUBLIC,
      :unit => asset,
      :asset => asset,
      :owner => person,
      :adhoc_currency => true
    }
    g = Group.create!(valid_attributes)
  end

  def create_person(options = {})
    Person.create!({ :password_confirmation => options[:password],
                     :accept_agreement => true,
                     :description => 'A new person' }.merge(options))
  end
end

