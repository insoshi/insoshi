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
      @membership = @p2.memberships.first(:conditions => ['group_id = ?',@g.id])
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
    end
  end
end
