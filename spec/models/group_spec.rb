require 'spec_helper'
require 'cancan/matchers'

describe Group do
  fixtures :client_applications, :people, :oauth_tokens, :groups

  before(:each) do
    @p = people(:quentin)
    @p2 = people(:aaron)
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description",
      :mode => Group::PUBLIC,
      :unit => "value for unit",
      :asset => "infinities",
      :owner => @p,
      :adhoc_currency => true
    }
    @g = Group.create!(@valid_attributes)
  end

  describe 'attributes' do
    it "should not be able to update someone else's group" do
      ability = Ability.new(@p2)
      ability.should_not be_able_to(:update,@g)
    end

    it "should be able to update own group" do
      ability = Ability.new(@p)
      ability.should be_able_to(:update,@g)
    end
  end

  describe 'roles' do
    before(:each) do
      Membership.request(@p2,@g,false)
      @membership = Membership.mem(@p2,@g)
      @ability = Ability.new(@p2)
    end

    describe 'attributes accessed by members' do
      it "should not allow an unauthorized member to update a group" do
        @membership.roles = ['individual']
        @membership.save
        @ability.should_not be_able_to(:update,@g)
      end

      it "should allow an admin member to update a group" do
        @membership.roles = ['individual','admin']
        @membership.save
        @ability.should be_able_to(:update,@g)
      end

      it "should not allow an admin member to update another admin membership" do
        @membership.roles = ['individual','admin']
        @membership.save

        @p3 = people(:buzzard)
        Membership.request(@p3,@g,false)
        @membership_sneaky_admin = Membership.mem(@p3,@g)
        @ability_sneaky_admin = Ability.new(@p3)
        @membership_sneaky_admin.roles = ['individual','admin']
        @membership_sneaky_admin.save
        @ability_sneaky_admin.should_not be_able_to(:update,@membership)
      end
    end

    describe 'forum posts made by non-members' do
      before(:each) do
        @forum = @g.forum
        @topic = @forum.topics.new(:name => 'test topic')
        @topic.person = @p
        @topic.save!
      end

      it "should allow a member to make a forum post" do
        Membership.request(@p2,@g,false)
        @membership = Membership.mem(@p2,@g)
        @ability = Ability.new(@p2)
        @forum_post = @topic.posts.build(:body => "Should we talk about the weather?")
        @forum_post.person = @p2
        @ability.should be_able_to(:create,@forum_post)
      end

      it "should not allow a non-member to make a forum post if forum is not world writable" do
        @forum.worldwritable = false
        @forum.save!

        @p3 = people(:buzzard)
        @ability_nonmember = Ability.new(@p3)
        @forum_post = @topic.posts.build(:body => "Should we talk about the weather?")
        @forum_post.person = @p3

        @ability_nonmember.should_not be_able_to(:create,@forum_post)
      end

      it "should allow a non-member to make a forum post if forum is world writable" do
        @forum.worldwritable = true
        @forum.save!

        @p3 = people(:buzzard)
        @ability_nonmember = Ability.new(@p3)
        @forum_post = @topic.posts.build(:body => "We have to do it in part as a matter of social responsibility to other people who are going to live in the world that we make.")
        @forum_post.person = @p3

        @ability_nonmember.should be_able_to(:create,@forum_post)
      end
    end

    describe 'offers made by people' do
      it "should not allow a non-member of a group to create an offer" do
        @p3 = people(:buzzard)
        @ability_nonmember = Ability.new(@p3)
        @offer = Offer.new(:name => "Pizza", :group => @g, :price => 5, :expiration_date => Date.today,:total_available => 1, :person => @p3)
        @ability_nonmember.should_not be_able_to(:create,@offer)
      end

      it "should allow a member of a group to create an offer" do
        @offer = Offer.new(:name => "Pizza", :group => @g, :price => 5, :expiration_date => Date.today,:total_available => 1, :person => @p2)
        @ability.should be_able_to(:create,@offer)
      end
    end

    describe 'exchanges made by members' do
      before(:each) do
        @req = Req.create!(:name => 'Generic',:estimated_hours => 0, :group => @g, :due_date => Time.now, :person => @p2, :active => false)
        @e = Exchange.new
        @e.metadata = @req
        @e.worker = @p
        @e.group = @g
        @e.amount = 1.0
      end

      it "should not allow a non-member of a group to make an exchange" do
        @p3 = people(:buzzard)
        @e.customer = @p3
        @ability_nonmember = Ability.new(@p3)
        @ability_nonmember.should_not be_able_to(:create,@e)
      end

      it "should not allow an individual member to make an unauthorized payment" do
        @e.customer = @p2
        @membership.roles = ['individual']
        @membership.save
        account = @p2.account(@g)
        account.balance = 0.0
        account.credit_limit = 0.5
        account.save!
        @ability.should_not be_able_to(:create,@e)
      end

      describe 'delegated payments with oauth' do
        before(:each) do
          @token = RequestToken.new :client_application => client_applications(:one), :callback_url => "http://example.com/callback"  
        end

        it "should not allow a payment with wrong scope type" do
          # _id = "read_payments"
          @token.scope = "http://localhost/scopes/list_payments.json?asset=#{@g.asset}"
          @token.save
          @token.authorize!(@p2)

          @token.provided_oauth_verifier = @token.verifier
          @access_token = @token.exchange!

          @scoped_ability = Ability.new(@p2,@access_token)
          @e.customer = @p2
          @scoped_ability.should_not be_able_to(:create,@e)
        end

        it "should allow a payment with the right scope type" do
          # _id = "single_payment"
          @token.scope = "http://localhost/scopes/single_payment.json?amount=10&asset=#{@g.asset}"
          @token.save
          @token.authorize!(@p2)

          @token.provided_oauth_verifier = @token.verifier
          @access_token = @token.exchange!

          @scoped_ability = Ability.new(@p2,@access_token)
          @e.customer = @p2
          @scoped_ability.should be_able_to(:create,@e)
        end

        it "should not allow a single payment that exceeds the authorized amount" do
          # _id = "single_payment"
          @token.scope = "http://localhost/scopes/single_payment.json?amount=0.5&asset=#{@g.asset}"
          @token.save
          @token.authorize!(@p2)

          @token.provided_oauth_verifier = @token.verifier
          @access_token = @token.exchange!

          @scoped_ability = Ability.new(@p2,@access_token)
          @e.customer = @p2
          @scoped_ability.should_not be_able_to(:create,@e)
        end

        it "should not allow a single payment to be made more than once" do
          # _id = "single_payment"
          @token.scope = "http://localhost/scopes/single_payment.json?amount=1&asset=#{@g.asset}"
          @token.save
          @token.authorize!(@p2)

          @token.provided_oauth_verifier = @token.verifier
          @access_token = @token.exchange!

          @scoped_ability = Ability.new(@p2,@access_token)
          @e.customer = @p2

          # first check, pay, invalidate
          if @scoped_ability.can? :create, @e
            @e.save
            # when access token present, invalidate on successful payment
            if @access_token.capabilities[0].action_id == 'single_payment'
              @access_token.capabilities[0].invalidate!
            end
          end
          @scoped_ability.should_not be_able_to(:create,@e)
        end
      end

      describe 'account balances' do
        before(:each) do
          @membership.roles = ['individual']
          @membership.save
          account = @p2.account(@g)
          account.balance = 10.0
          account.save!
          @e.customer = @p2
        end

        it "should update account balance when a payment is created" do
          @e.save!
          account_after_payment = @p2.account(@g)
          account_after_payment.balance.should == 9.0
        end

        it "should update account balance when a payment is deleted" do
          @e.save!
          @e.destroy
          account_after_payment_deletion = @p2.account(@g)
          account_after_payment_deletion.balance.should == 10.0
        end
      end
    end
  end

  describe 'group default credit limit' do
    before(:each) do
      @g.default_credit_limit = 40.0
    end

    it "should set the account balance of a new member" do
      Membership.request(@p2,@g,false)
      account = @p2.account(@g)
      account.credit_limit.should == 40.0
    end

    it "should update the account balance of an existing member when update" do
      Membership.request(@p2,@g,false)
      @g.default_credit_limit = 50.0
      @g.save
      account = @p2.account(@g)
      account.credit_limit.should == 50.0
    end
  end
end
