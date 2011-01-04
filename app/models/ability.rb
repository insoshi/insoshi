class Ability
  include CanCan::Ability
  def initialize(person)
    can [:read, :create], Group
    can [:new_req,:create_req], Group
    can [:new_offer,:create_offer], Group
    can [:update,:destroy], Group, :owner => person
    can :update, Group do |group|
      membership = Membership.mem(person,group)
      membership && membership.is?(:admin)
    end
    can [:members,:exchanges], Group
    can [:new_photo,:save_photo,:delete_photo], Group, :owner => person

    can :read, Membership
    can :create, Membership
    can :destroy, Membership, :person => person
    can [:update,:suscribe,:unsuscribe], Membership do |membership|
      person.is?(:admin,membership.group)
    end

    can :read, Account
    can :update, Account do |account|
      person.is?(:admin,account.group)
    end

    can :read, Offer
    can :create, Offer do |offer|
      Membership.mem(person,offer.group)
    end
    can [:update,:destroy], Offer, :person => person

    can :read, Req
    can :create, Req do |req|
      Membership.mem(person,req.group)
    end
    can [:update,:destroy], Req, :person => person

    can :read, Exchange
    can :destroy, Exchange, :customer => person
    can :create, Exchange do |exchange|
      unless exchange.group
        # the presence of group is validated when creating an exchange
        # group will be nil for the new method, so allow it
        true
      else
        membership = Membership.mem(person,exchange.group)
        unless membership
          false
        else
          account = person.account(exchange.group)
          account && (account.authorized? exchange.amount)
        end
      end
    end
  end
end
