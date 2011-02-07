require 'spec_helper'
require 'cancan/matchers'

describe Group do
  before(:each) do
    @p = people(:quentin)
    @p2 = people(:aaron)
    @valid_attributes = {
      :name => "value for name",
      :description => "value for description",
      :mode => Group::PUBLIC,
      :unit => "value for unit",
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
end
