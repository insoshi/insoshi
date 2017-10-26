# == Schema Information
#
# Table name: people
#
#  id                       :integer          not null, primary key
#  email                    :string(255)
#  name                     :string(255)
#  crypted_password         :string(255)
#  password_salt            :string(255)
#  persistence_token        :string(255)
#  description              :text
#  last_contacted_at        :datetime
#  last_logged_in_at        :datetime
#  forum_posts_count        :integer          default(0), not null
#  created_at               :datetime
#  updated_at               :datetime
#  admin                    :boolean          default(FALSE), not null
#  deactivated              :boolean          default(FALSE), not null
#  connection_notifications :boolean          default(TRUE)
#  message_notifications    :boolean          default(TRUE)
#  email_verified           :boolean
#  identity_url             :string(255)
#  phone                    :string(255)
#  first_letter             :string(255)
#  zipcode                  :string(255)
#  phoneprivacy             :boolean          default(TRUE)
#  language                 :string(255)
#  openid_identifier        :string(255)
#  perishable_token         :string(255)      default(""), not null
#  default_group_id         :integer
#  org                      :boolean          default(FALSE)
#  activator                :boolean          default(FALSE)
#  sponsor_id               :integer
#  broadcast_emails         :boolean          default(TRUE), not null
#  web_site_url             :string(255)
#  business_name            :string(255)
#  legal_business_name      :string(255)
#  business_type_id         :integer
#  title                    :string(255)
#  activity_status_id       :integer
#  fee_plan_id              :integer
#  support_contact_id       :integer
#  mailchimp_subscribed     :boolean          default(FALSE)
#  time_zone                :string(255)
#  date_style               :string(255)
#  posts_per_page           :integer          default(25)
#  stripe_id                :string(255)
#  requires_credit_card     :boolean          default(TRUE)
#  rollover_balance         :decimal(, )      default(0.0)
#  plan_started_at          :datetime
#  display_name             :string(255)
#  visible                  :boolean          default(TRUE)
#  update_card              :boolean          default(FALSE)
#  junior_admin             :boolean          default(FALSE)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Person do

  fixtures :fee_plans

  before(:each) do
    @person = people(:quentin)
  end

  describe "attributes" do
    it "should be valid" do
      create_person.should be_valid
    end

    it 'requires password' do
      p = create_person(:password => nil)
      p.errors[:password].should_not be_nil
    end

    it 'requires password confirmation' do
      p = create_person(:password_confirmation => nil)
      p.errors[:password_confirmation].should_not be_nil
    end

    it 'requires email' do
      p = create_person(:email => nil)
      p.errors[:email].should_not be_nil
    end

    it "should prevent duplicate email addresses using a unique key" do
      create_person(:save => true)
      duplicate = create_person
      lambda do
        # Pass 'false' to 'save' in order to skip the validations.
        duplicate.save(validate: false)
      end.should raise_error(ActiveRecord::StatementInvalid)
    end

    it "should require name" do
      p = create_person(:name => nil)
      p.errors[:name].should_not be_nil
    end

    it "should strip spaces in email field" do
      create_person(:email => 'example@example.com ').should be_valid
    end

    it "should be valid even with a nil description" do
      p = create_person(:description => nil)
      p.should be_valid
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
  end

  describe "message associations" do
    it "should have sent messages" do
      @person.sent_messages.should_not be_nil
    end

    it "should have received messages" do
      @person.received_messages.should_not be_nil
    end
  end

  describe "activation" do

    it "should deactivate a person" do
      @person.should_not be_deactivated
      @person.toggle(:deactivated)
      @person.should be_deactivated
    end

    it "after deactivate should be in 'Closed' plan" do
      @pref = preferences(:one)
      @fee_plan = fee_plans(:closed)
      @pref.default_deactivated_fee_plan_id = @fee_plan.id
      @pref.save

      @person.deactivated = true
      @person.save
      @person.fee_plan.name.should eq('Closed')
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

    it "should hide and show connected requests after deactivation and then activation of user" do
      group = created_group_id(@person)
      @person.default_group_id = group.id
      @person.save
      create_request_like(@person, group)

      Req.custom_search(nil, group, true, 1, 25, nil).should_not be_empty
      @person.deactivated = true
      @person.save

      Req.custom_search(nil, group, true, 1, 25, nil).should be_empty
      @person.deactivated = false
      @person.save
      Req.custom_search(nil, group, true, 1, 25, nil).should_not be_empty
    end

    it "should hide and show connected offers after deactivation and then activation of user" do
      group = created_group_id(@person)
      @person.default_group_id = group.id
      @person.save
      create_offer_like(@person, group)

      Offer.custom_search(nil, group, true, 1, 25, nil).should_not be_empty
      @person.deactivated = true
      @person.save

      Offer.custom_search(nil, group, true, 1, 25, nil).should be_empty
      @person.deactivated = false
      @person.save
      Offer.custom_search(nil, group, true, 1, 25, nil).should_not be_empty
    end

  end

  describe "mostly active" do
    it "should include a recently logged-in person" do
      Person.mostly_active.should contain(@person)
    end

    pending "should not include a deactivated person" do
      @person.toggle!(:deactivated)
      Person.mostly_active.should_not contain(@person)
    end

    pending "should not include an email unverified person" do
      enable_email_notifications
      @person.email_verified = false; @person.save!
      Person.mostly_active.should_not contain(@person)
    end

    it "should not include a person who has never logged in" do
      @person.last_logged_in_at = nil; @person.save
      Person.mostly_active.should_not contain(@person)
    end

    it "should not include a person who logged in too long ago" do
      @person.last_logged_in_at = Person::TIME_AGO_FOR_MOSTLY_ACTIVE.ago - 1
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
      Person.active.should_not contain(@person)
    end

    pending "should not return email unverified people" do
      @person.email_verified = false
      @person.save!
      Person.active.should_not contain(@person)
    end
  end

  describe "stripe associated methods" do
    before(:each) do
      @fee_plan = FeePlan.new(name: 'with stripe plans')
      @fee_plan.save!
      stripe_fee = FixedTransactionStripeFee.new(fee_plan: @fee_plan, amount: 1)
      stripe_fee.save!
      @person.fee_plan = @fee_plan
    end

    it "should return true if person got fee plan with any stripe fees" do
      @person.have_monetary_fee_plan?.should be_true
    end

    it "should return true if person needs to submit their credit card credentials" do
      @person.stripe_id = nil
      @person.credit_card_required?.should be_true
    end

    it "should be possible for admin to override forcing credit card credentials" do
      @person.requires_credit_card = false
      @person.credit_card_required?.should_not be_true
    end
  end

  describe "your requests" do
    it "should not include requests associated with direct payments" do
      group = created_group_id(@person)
      @person.default_group_id = group.id
      @person.save
      pseudo_req = create_request_like(@person, group, false)
      @person.reqs_for_group(group).should_not contain(pseudo_req)
    end

    it "should include real requests" do
      group = created_group_id(@person)
      @person.default_group_id = group.id
      @person.save
      real_req = create_request_like(@person, group, true)
      @person.reqs_for_group(group).should contain(real_req)
    end
  end

  protected

    def create_request_like(person, group, biddable = true)
      request = Req.new( {
        :name => 'test req',
        :due_date => DateTime.now+1,
        :biddable => biddable
        })
      request.person_id = person.id
      request.group_id = group.id
      request.valid?
      request.save!
      request
    end

    def create_offer_like(person, group)
      offer = Offer.new({
        :description => 'test offer description',
        :available_count => 1,
        :group_id => group.id,
        :name => 'test offer',
        :expiration_date => DateTime.now + 1.day
        })
      offer.person_id = person.id

      offer.valid?
      offer.save!
      offer
    end

    def created_group_id(person)
      group = Group.new({
        :name => "test group",
        :description => "test group description"
        })
      group.update_attribute(:person_id, person.id)

      group.valid?
      group.save!
      group
    end

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
