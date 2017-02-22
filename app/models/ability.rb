class Ability
  extend PreferencesHelper
  include CanCan::Ability
  def initialize(person, access_token = nil)

    alias_action :create, :read, :update, :destroy, :to => :crud

    can :su, Person do |target_person|
      person.admin? && !target_person.admin?
    end
    can :unsu, Person

    if person.admin?
      can :dashboard
      can [:read,:create,:destroy], Fee
      can [:read,:create,:destroy], StripeFee
      can [:read,:create,:update,:destroy], FixedTransactionFee
      can [:read,:create,:update,:destroy], PercentTransactionFee
      can [:read,:create,:update,:destroy], RecurringFee
      can [:read,:create,:update,:destroy], FixedTransactionStripeFee
      can [:read,:create,:update,:destroy], PercentTransactionStripeFee
      can [:read,:create,:destroy], RecurringStripeFee
      can [:read, :refund_money, :dispute_link], Charge
      can [:crud], Message
      can [:read,:create,:destroy], AccountImport, person_id: person.id if person
    end

    # need these for rails_admin
    can [:manage], Address
    can [:manage], State
    can [:read,:update], TimeZone

    can [:read,:create,:update], SystemMessageTemplate

    can [:read,:create], Person
    can :update, Person do |target_person|
      target_person == person || person.admin?
    end

    can :add_to_mailchimp_list, Person
    can :export, Person
    can :view_transactions, Person do |transact_owner|
      person.id == transact_owner.id
    end

    can :read, PrivacySetting
    can :update, PrivacySetting do |ps|
      membership = Membership.mem(person,ps.group)
      (membership && membership.is?(:admin)) || person.admin?
    end

    can :read, BusinessType
    can [:create,:update,:destroy], BusinessType do |bt|
      person.admin?
    end

    can :read, ActivityStatus
    can [:create,:update,:destroy], ActivityStatus do |as|
      person.admin?
    end

    can :read, FeePlan
    can [:create,:update,:destroy], FeePlan do |fp|
      person.admin?
    end

    can :read, FeedPost
    can [:update,:destroy], FeedPost do |post|
      person.admin?
    end

    can :read, Preference
    cannot :read, Preference if person.junior_admin?
    can :update, Preference do |pref|
      person.admin?
    end

    can :read, BroadcastEmail
    can [:create,:update,:send_broadcast_email], BroadcastEmail do |broadcast_email|
      person.admin?
    end

    # adding category,neighborhood to rails_admin
    can :read, Category
    can :create, Category do |category|
      person.admin? || !(Ability.global_prefs.protected_categories?)
    end
    can [:update,:destroy], Category do |category|
      person.admin?
    end

    can :read, Neighborhood
    can [:create,:update,:destroy], Neighborhood do |neighborhood|
      person.admin?
    end

    can [:read], Group
    can [:create], Group do
      Preference.first.groups?
    end
    can [:new_req,:create_req], Group
    can [:new_offer,:create_offer], Group
    can [:update,:new_photo,:save_photo,:delete_photo,:destroy], Group do |group|
      membership = Membership.mem(person,group)
      membership && membership.is?(:admin)
    end
    can [:members,:exchanges,:graphs,:people], Group

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

    can [:read,:create], Forum
    can [:update,:destroy], Forum do |forum|
      person.is?(:admin,forum.group) || person.admin?
    end

    can :read, Membership
    can :create, Membership
    can :destroy, Membership, :person => person
    can [:update,:suscribe,:unsuscribe], Membership do |membership|
      person.is?(:admin,membership.group) and !(membership.is?(:admin) and (person != membership.person))
    end

    can :update, MemberPreference do |member_preference|
      member_preference.membership.person == person
    end

    can :read, Account
    cannot :read, Account if person.junior_admin?
    can :update, Account do |account|
      # XXX excluding the specified account from the sum would be correct math but probably not worth it
      person.is?(:admin,account.group) and ((account.reserve_percent || 0) + account.group.sum_reserves) < 1.0
    end
    can :export, Account

    can :read, Offer
    can :create, Offer do |offer|
      Membership.mem(person,offer.group) || person.junior_admin?# XXX check for approved membership for groups that require approval
    end
    can [:update,:new_photo,:save_photo], Offer do |offer|
      person.is?(:admin,offer.group) || offer.person == person || person.admin? || person.junior_admin?
    end
    can :destroy, Offer do |offer|
      # if an exchange already references an offer, don't allow the offer to be deleted
      referenced = offer.exchanges.length > 0
      !referenced && (person.is?(:admin,offer.group) || offer.person == person || person.admin? || person.junior_admin?)
    end

    can :read, Req
    can :create, Req do |req|
      Membership.mem(person,req.group) # XXX check for approved membership for groups that require approval
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

    can :read, Bid do |bid|
      PublicBid.close? || bid.req.public_bid || bid.req.person == person || bid.person == person
    end
    can :create, Bid do |bid|
      Membership.mem(person,bid.req.group)
    end
    can :update, Bid do |bid|
      person.admin? || bid.person == person || bid.req.person == person
    end
    can :destroy, Bid do |bid|
      bid.person == person
    end

    can [:read, :create,:update,:destroy], FormSignupField
    can [:read, :create,:update,:destroy], PersonMetadatum

    can :read, Exchange
    cannot :read, Exchange if person.junior_admin?
    can :destroy, Exchange do |exchange|
      (exchange.class != ExchangeDeleted) && (exchange.customer == person || person.admin?)
    end
    can :create, Exchange do |exchange|
      unless exchange.group
        # the presence of group is validated when creating an exchange
        # group will be nil for the new method, so allow it
        true
      else
        membership = Membership.mem(person,exchange.group)
        unless membership # XXX check for approved membership for groups that require approval
          false
        else
          payer = exchange.customer || person
          # reject oauth payment if it exceeds amount user authorized
          if access_token.present? and not access_token.authorized_for?(exchange.amount)
            false
          # now it's not logged-in person's account we test but customer's account
          elsif !(payer.account(exchange.group).authorized?(exchange.amount))
            false
          else
            # in oauth land, token always represents payer, so oauth payment is forbidden if exchange.customer != person.
            payer == person || (access_token.nil? and ((membership.is?(:point_of_sale_operator) and exchange.worker == person) || membership.is?(:admin) || person.admin?))
          end
        end
      end
    end

    can :manage, Report

    can :access, :rails_admin do |rails_admin|
      person.admin? || person.junior_admin?
    end

    can :dashboard if person.junior_admin?

  end
end
