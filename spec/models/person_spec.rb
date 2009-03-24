require File.dirname(__FILE__) + '/../spec_helper'

describe Person do

  before(:each) do
    @person = people(:quentin)
  end

  describe "attributes" do
    it "should be valid" do
      create_person.should be_valid
    end

    it 'requires password' do
      p = create_person(:password => nil)
      p.errors.on(:password).should_not be_nil
    end

    it 'requires password confirmation' do
      p = create_person(:password_confirmation => nil)
      p.errors.on(:password_confirmation).should_not be_nil
    end

    it 'requires email' do
      p = create_person(:email => nil)
      p.errors.on(:email).should_not be_nil
    end
    
    it "should prevent duplicate email addresses using a unique key" do
      create_person(:save => true)
      duplicate = create_person
      lambda do
        # Pass 'false' to 'save' in order to skip the validations.
        duplicate.save(false)
      end.should raise_error(ActiveRecord::StatementInvalid)
    end

    it "should require name" do
      p = create_person(:name => nil)
      p.errors.on(:name).should_not be_nil
    end

    it "should strip spaces in email field" do
      create_person(:email => 'example@example.com ').should be_valid
    end
    
    it "should allow a plus sign in the email address" do
      create_person(:email => 'foo+bar@example.com').should be_valid
    end
    
    it "should be valid even with a nil description" do
      p = create_person(:description => nil)
      p.should be_valid
    end
  end
  
  describe "length validations" do
    it "should enforce a maximum name length" do
      @person.should have_maximum(:name, Person::MAX_NAME)
    end
    
    it "should enforce a maximum description length" do
      @person.should have_maximum(:description, Person::MAX_DESCRIPTION)
    end
  end

  describe "activity associations" do

    it "should log an activity if description changed" do
      @person.update_attributes(:description => "New Description")
      activity = Activity.find_by_item_id(@person)
      Activity.global_feed.should contain(activity)
    end

    it "should not log an activity if description didn't change" do
      @person.save!
      activity = Activity.find_by_item_id(@person)
      Activity.global_feed.should_not contain(activity)
    end

    it "should disappear if the person is destroyed" do
      person = create_person(:save => true)
      # Create a feed activity.
      Connection.connect(person, @person)
      @person.update_attributes(:name => "New name")

      Activity.find_all_by_person_id(person).should_not be_empty
      person.destroy
      Activity.find_all_by_person_id(person).should be_empty
      Feed.find_all_by_person_id(person).should be_empty
    end

    it "should disappear from other feeds if the person is destroyed" do
      initial_person = create_person(:save => true)
      person         = create_person(:email => "new@foo.com", :name => "Foo",
                                     :save => true)
      Connection.connect(person, initial_person)
      initial_person.activities.length.should == 1
      person.destroy
      initial_person.reload.activities.length.should == 0
    end
  end

  describe "utility methods" do
    it "should have the right to_param method" do
      # Person params should have the form '1-michael-hartl'.
      param = "#{@person.id}-quentin"
      @person.to_param.should == param
    end

    it "should have a safe uri" do
      @person.name = "Michael & Hartl"
      param = "#{@person.id}-michael-and-hartl"
      @person.to_param.should == param
    end
  end

  describe "contact associations" do
    it "should have associated photos" do
      @person.photos.should_not be_nil
    end

    it "should not currently have any photos" do
      @person.photos.should be_empty
    end

    it "should have an associated blog on creation" do
      person = create_person(:save => true)
      person.blog.should_not be_nil
    end

    it "should have many wall comments" do
      @person.comments.should be_a_kind_of(Array)
      @person.comments.should_not be_empty
    end

    it "should be connected to the admin" do
      person = create_person(:save => true)
      admin = people(:admin)
      person.contacts.first.should == admin
    end

    it "should not include deactivated users" do
      contact = people(:aaron)
      Connection.connect(@person, contact)
      @person.contacts.should contain(contact)
      contact.toggle!(:deactivated)
      @person.reload.contacts.should_not contain(contact)
    end

    it "should not include email unverified users" do
      contact = people(:aaron)
      Connection.connect(@person, contact)
      @person.contacts.should contain(contact)
      enable_email_notifications
      contact.email_verified = false ; contact.save!
      @person.reload.contacts.should_not contain(contact)
    end
  end

  describe "associations" do

    before(:each) do
      @contact = people(:aaron)
    end

    # TODO: make custom matchers to get @contact.should have_requested_contacts
    it "should have requested contacts" do
      Connection.request(@person, @contact)
      @contact.requested_contacts.should_not be_empty
    end

    it "should have contacts" do
      Connection.connect(@person, @contact)
      @person.contacts.should == [@contact]
      @contact.contacts.should == [@person]
    end

    describe "common contacts" do

      before(:each) do
        @kelly = people(:kelly)
        Connection.connect(@person, @contact)
        Connection.connect(@kelly, @contact)
      end

      it "should have common contacts with someone" do
        common_contacts = @person.common_contacts_with(@kelly)
        common_contacts.size.should == 1
        common_contacts.should be_a_kind_of(WillPaginate::Collection)
        common_contacts.should == [@contact]
      end

      it "should not include non-common contacts" do
        admin = people(:admin)
        Connection.connect(@person, admin)
        @person.common_contacts_with(@kelly).should_not contain(admin)
      end

      it "should exclude deactivated people from common contacts" do
        @contact.toggle!(:deactivated)
        common_contacts = @person.common_contacts_with(@kelly)
        common_contacts.should be_empty
      end
      
      it "should exclude email unverified people from common contacts" do
        enable_email_notifications
        @contact.email_verified = false; @contact.save!
        common_contacts = @person.common_contacts_with(@kelly)
        common_contacts.should be_empty
      end
      
      it "should exclude the person being viewed" do
        Connection.connect(@person, @kelly)
        @person.common_contacts_with(@kelly).should_not contain(@kelly)
      end
      
      it "should exclude the person doing the viewing" do
        Connection.connect(@person, @kelly)
        @person.common_contacts_with(@kelly).should_not contain(@person)
      end
    end
  end

  describe "photo methods" do

    before(:each) do
      @photo_1 = mock_photo(:avatar => true)
      @photo_2 = mock_photo
      @photos = [@photo_1, @photo_2]
      @photos.stub!(:find_all_by_avatar).and_return([@photo_1])
      @person.stub!(:photos).and_return(@photos)
    end

    it "should have a photo method" do
      @person.should respond_to(:photo)
    end

    it "should have a non-nil primary photo" do
      @person.photo.should_not be_nil
    end

    it "should have other photos" do
      @person.other_photos.should_not be_empty
    end

    it "should have the right other photos" do
      @person.other_photos.should == (@photos - [@person.photo])
    end

    it "should have a main photo" do
      @person.main_photo.should == @person.photo.public_filename
    end

    it "should have a thumbnail" do
      @person.thumbnail.should_not be_nil
    end

    it "should have an icon" do
      @person.icon.should_not be_nil
    end

    it "should have sorted photos" do
      @person.sorted_photos.should == [@photo_1, @photo_2]
    end
  end

  describe "message associations" do
    it "should have sent messages" do
      @person.sent_messages.should_not be_nil
    end

    it "should have received messages" do
      @person.received_messages.should_not be_nil
    end
    
    it "should have unread messages" do
      @person.has_unread_messages?.should be_true
    end
  end

  describe "authentication" do
    it 'resets password' do
      @person.update_attributes(:password => 'newp',
                                :password_confirmation => 'newp')
      Person.authenticate('quentin@example.com', 'newp').should == @person
    end

    it 'authenticates person' do
      Person.authenticate('quentin@example.com', 'test').should == @person
    end

    it "should strip spaces for email" do
      Person.authenticate('quentin@example.com ', 'test').should == @person
    end

    it "should authenticate case-insensitively" do
      Person.authenticate('queNTin@eXample.com', 'test').should == @person
    end

    it 'sets remember token' do
      @person.remember_me
      @person.remember_token.should_not be_nil
      @person.remember_token_expires_at.should_not be_nil
    end

    it 'unsets remember token' do
      @person.remember_me
      @person.remember_token.should_not be_nil
      @person.forget_me
      @person.remember_token.should be_nil
    end

    it 'remembers me for one week' do
      before = 1.week.from_now.utc
      @person.remember_me_for 1.week
      after = 1.week.from_now.utc
      @person.remember_token.should_not be_nil
      @person.remember_token_expires_at.should_not be_nil
      @person.remember_token_expires_at.between?(before, after).should be_true
    end

    it 'remembers me until one week' do
      time = 1.week.from_now.utc
      @person.remember_me_until time
      @person.remember_token.should_not be_nil
      @person.remember_token_expires_at.should_not be_nil
      @person.remember_token_expires_at.should == time
    end

    it 'remembers me default two weeks' do
      before = 2.years.from_now.utc
      @person.remember_me
      after = 2.years.from_now.utc
      @person.remember_token.should_not be_nil
      @person.remember_token_expires_at.should_not be_nil
      @person.remember_token_expires_at.between?(before, after).should be_true
    end
  end

  describe "password edit" do

    before(:each) do
      @password = @person.unencrypted_password
      @newpass  = "foobar"
    end

    it "should change the password" do
      @person.change_password?(:verify_password       => @password,
                               :new_password          => @newpass,
                               :password_confirmation => @newpass)
      @person.unencrypted_password.should == @newpass
    end

    it "should not change password on failed verification" do
      @person.change_password?(:verify_password       => @password + "not!",
                               :new_password          => @newpass,
                               :password_confirmation => @newpass)
      @person.unencrypted_password.should_not == @newpass
      @person.errors.on(:password).should =~ /incorrect/
    end

    it "should not change password on failed agreement" do
      @person.change_password?(:verify_password       => @password,
                               :new_password          => @newpass + "not!",
                               :password_confirmation => @newpass)
      @person.unencrypted_password.should_not == @newpass
      @person.errors.on(:password).should =~ /match/
    end

    it "should not allow invalid new password" do
      @newpass = ""
      @person.change_password?(:verify_password       => @password,
                               :new_password          => @newpass,
                               :password_confirmation => @newpass)
      @person.unencrypted_password.should_not == @newpass
      @person.errors.on(:password).should_not be_nil
    end
  end

  describe "activation" do

    it "should deactivate a person" do
      @person.should_not be_deactivated
      @person.toggle(:deactivated)
      @person.should be_deactivated
    end

    it "should reactivate a person" do
      @person.toggle(:deactivated)
      @person.should be_deactivated
      @person.toggle(:deactivated)
      @person.should_not be_deactivated
    end
    
    it "should have nil email verification" do
      person = create_person
      person.email_verified.should be_nil
    end

    it "should have a working active? helper boolean" do
      @person.should be_active
      enable_email_notifications
      @person.email_verified = false
      @person.should_not be_active
      @person.email_verified = true
      @person.should be_active
    end
  end
  
  describe "mostly active" do
    it "should include a recently logged-in person" do
      Person.mostly_active.should contain(@person)
    end
    
    it "should not include a deactivated person" do
      @person.toggle!(:deactivated)
      Person.mostly_active.should_not contain(@person)
    end
    
    it "should not include an email unverified person" do
      enable_email_notifications
      @person.email_verified = false; @person.save!
      Person.mostly_active.should_not contain(@person)      
    end
    
    it "should not include a person who has never logged in" do
      @person.last_logged_in_at = nil; @person.save
      Person.mostly_active.should_not contain(@person)
    end
    
    it "should not include a person who logged in too long ago" do
      @person.last_logged_in_at = Person::TIME_AGO_FOR_MOSTLY_ACTIVE - 1
      @person.save
      Person.mostly_active.should_not contain(@person)
    end
  end

  describe "admin" do

    before(:each) do
      @person = people(:admin)
    end

    it "should un-admin a person" do
      @person.should be_admin
      @person.toggle(:admin)
      @person.should_not be_admin
    end

    it "should have a working last_admin? method" do
      @person.should be_last_admin
      people(:aaron).toggle!(:admin)
      @person.should_not be_last_admin
    end
  end
  
  describe "active class methods" do
    it "should not return deactivated people" do
      @person.toggle!(:deactivated)
      [:active, :all_active].each do |method|
        Person.send(method).should_not contain(@person)
      end
    end
    
    it "should not return email unverified people" do
      @person.email_verified = false
      @person.save!
      [:active, :all_active].each do |method|
        Person.send(method).should_not contain(@person)
      end
    end
  end
    
  protected

    def create_person(options = {})
      record = Person.new({ :email => 'quire@example.com',
                            :password => 'quire',
                            :password_confirmation => 'quire',
                            :name => 'Quire',
                            :description => 'A new person' }.merge(options))
      record.valid?
      record.save! if options[:save]
      record
    end
end
