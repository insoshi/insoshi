class Ability
  include CanCan::Ability
  def initialize(person, access_token = nil)

    can :su, Person do |target_person|
      person.admin? && !target_person.admin?
    end

    if person.admin?
      can :dashboard
    end

    # need these for rails_admin
    can [:read,:create], Person
    can :update, Person do |target_person|
      target_person == person || person.admin?
    end
    can :export, Person

    can :read, BusinessType
    can [:create,:update,:destroy], BusinessType do |bt|
      person.admin?
    end

    can :read, ActivityStatus
    can [:create,:update,:destroy], ActivityStatus do |as|
      person.admin?
    end

    can :read, PlanType
    can [:create,:update,:destroy], PlanType do |pt|
      person.admin?
    end

    can :read, FeedPost
    can [:update,:destroy], FeedPost do |post|
      person.admin?
    end

    can :read, Preference
    can :update, Preference do |pref|
      person.admin?
    end

    can :read, BroadcastEmail
    can [:create,:update,:send_broadcast_email], BroadcastEmail do |broadcast_email|
      person.admin?
    end

    # adding category,neighborhood to rails_admin
    can [:read,:create], Category
    can [:update], Category do |category|
      person.admin?
    end

    can :read, Neighborhood
    can [:create,:update], Neighborhood do |neighborhood|
      person.admin?
    end

    can [:read, :create], Group
    can [:new_req,:create_req], Group
    can [:new_offer,:create_offer], Group
    can [:update,:new_photo,:save_photo,:delete_photo,:destroy], Group do |group|
      membership = Membership.mem(person,group)
      membership && membership.is?(:admin)
    end
    can [:members,:exchanges,:graphs], Group

    can :read, Topic
    can :create, Topic do |topic|
      topic.forum.worldwritable? || Membership.mem(person,topic.forum.group)
    end
    can :destroy, Topic do |topic|
      person.is?(:admin,topic.forum.group) || person.admin?
    end

    can :read, ForumPost
    can :create, ForumPost do |post|
      post.topic.forum.worldwritable? || Membership.mem(person,post.topic.forum.group)
    end
    can :update, ForumPost do |post|
      person.admin?
    end
    can :destroy, ForumPost do |post|
      person.is?(:admin,post.topic.forum.group) || post.person == person || person.admin?
    end

    can :read, Membership
    can :create, Membership
    can :destroy, Membership, :person => person
    can [:update,:suscribe,:unsuscribe], Membership do |membership|
      person.is?(:admin,membership.group) && !membership.is?(:admin)
    end

    can :update, MemberPreference do |member_preference|
      member_preference.membership.person == person
    end

    can :read, Account
    can :update, Account do |account|
      person.is?(:admin,account.group)
    end
    can :export, Account


    can :read, Offer
    can :create, Offer do |offer|
      Membership.mem(person,offer.group)
    end
    can :update, Offer do |offer|
      person.is?(:admin,offer.group) || offer.person == person || person.admin?
    end
    can :destroy, Offer do |offer|
      # if an exchange already references an offer, don't allow the offer to be deleted
      referenced = offer.exchanges.length > 0
      !referenced && (person.is?(:admin,offer.group) || offer.person == person || person.admin?)
    end

    can :read, Req
    can :create, Req do |req|
      Membership.mem(person,req.group)
    end
    can :update, Req do |req|
      referenced = req.has_accepted_bid? # no update after someone has bid on it
      !referenced && (person.is?(:admin,req.group) || req.person == person || person.admin?)
    end
    can :destroy, Req do |req|
      referenced = req.has_commitment? || req.has_approved? # no delete after a worker commits
      !referenced && (person.is?(:admin,req.group) || req.person == person || person.admin?)
    end
    can :deactivate, Req do |req|
      person.is?(:admin,req.group) || req.person == person || person.admin?
    end

    can :read, Exchange
    can :destroy, Exchange do |exchange|
      exchange.customer == person || person.admin?
    end
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
          unless (access_token.nil? || access_token.authorized_for?(exchange.amount))
            false
          else
            account = person.account(exchange.group)
            account && (account.authorized? exchange.amount)
          end
        end
      end
    end

    can :access, :rails_admin do |rails_admin|
      person.admin?
    end
  end
end
