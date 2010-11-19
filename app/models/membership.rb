class Membership < ActiveRecord::Base
  extend ActivityLogger
  extend PreferencesHelper
  
  named_scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0"} }

  belongs_to :group
  belongs_to :person
  has_many :activities, :foreign_key => "item_id", :conditions => "item_type = 'Membership'" #, :dependent => :destroy

  validates_presence_of :person_id, :group_id
  
  # Status codes.
  ACCEPTED  = 0
  INVITED   = 1 # deprecated
  PENDING   = 2
  
  ROLES = %w[individual admin moderator org]

  # Accept a membership request (instance method).
  def accept
    Membership.accept(person, group)
  end
  
  def breakup
    Membership.breakup(person, group)
  end

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def add_role(new_role)
    a = self.roles
    a << new_role
    self.roles = a
  end

  def roles
    ROLES.reject do |r|
      ((roles_mask || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def is?(role)
    roles.include?(role.to_s)
  end

  class << self
    
    # Return true if the person is member of the group.
    def exists?(person, group)
      not mem(person, group).nil?
    end
    
    alias exist? exists?
    
    # Make a pending membership request.
    def request(person, group, send_mail = nil)
      if send_mail.nil?
        send_mail = global_prefs.email_notifications? &&
                    group.owner.connection_notifications?
      end
      if person.groups.include?(group) or Membership.exists?(person, group)
        nil
      else
        if group.public? or group.private?
          transaction do
            create(:person => person, :group => group, :status => PENDING)
            if send_mail
              membership = person.memberships.find(:first, :conditions => ['group_id = ?',group])
              PersonMailer.deliver_membership_request(membership)
            end
          end
          if group.public?
            Membership.accept(person,group)
            if send_mail
              membership = person.memberships.find(:first, :conditions => ['group_id = ?',group])
              PersonMailer.deliver_membership_public_group(membership)
            end
          end
        end
        true
      end
    end
    
    # Accept a membership request.
    def accept(person, group)
      transaction do
        accepted_at = Time.now
        accept_one_side(person, group, accepted_at)
      end
      log_activity(mem(person, group))
    end
    
    def breakup(person, group)
      transaction do
        destroy(mem(person, group))
      end
    end
    
    def mem(person, group)
      find_by_person_id_and_group_id(person, group)
    end
    
    def accepted?(person, group)
      mem(person, group).status == ACCEPTED
    end
    
    def connected?(person, group)
      exist?(person, group) and accepted?(person, group)
    end
    
    def pending?(person, group)
      exist?(person, group) and mem(person,group).status == PENDING
    end
    
  end
  
  private
  
  class << self
    # Update the db with one side of an accepted connection request.
    def accept_one_side(person, group, accepted_at)
      mem = mem(person, group)
      mem.status = ACCEPTED
      mem.accepted_at = accepted_at
      mem.add_role('individual')
      mem.save

      if person.accounts.find(:first,:conditions => ["group_id = ?",group.id]).nil?
        account = Account.new( :name => group.name ) # group name can change
        account.balance = Account::INITIAL_BALANCE 
        account.person = person
        account.group = group
        account.credit_limit = group.default_credit_limit
        account.save
      end
    end
  
    def log_activity(membership)
      activity = Activity.create!(:item => membership, :person => membership.person)
      add_activities(:activity => activity, :person => membership.person)
    end
  end
  
end
