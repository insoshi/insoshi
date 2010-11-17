class Ability
  include CanCan::Ability
  def initialize(person)
    can [:read, :show_default, :create], Group
    can [:new_req,:create_req], Group
    can [:new_offer,:create_offer], Group
    can [:update,:destroy], Group, :owner => person
    can :update, Group do |group|
      membership = Membership.mem(person,group)
      membership && membership.is?(:admin)
    end
    can :members, Group
    can [:new_photo,:save_photo,:delete_photo], Group, :owner => person

    can :read, Exchange
    can :destroy, Exchange, :customer => person
    can :create, Exchange do |exchange|
      unless exchange.group
        # all exchanges are associated with a group
        false
      else
        membership = Membership.mem(person,exchange.group)
        unless membership
          false
        else
          account = Account.find_by_person_id_and_group_id(person, exchange.group)
          account && (account.authorized? exchange.amount)
        end
      end
    end
  end
end
