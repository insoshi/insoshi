unless Rails.env == 'test'
require Rails.root.join('lib', 'rails_admin_send_broadcast_email.rb')
require Rails.root.join('lib', 'rails_admin_add_to_mailchimp_list.rb')
require Rails.root.join('lib', 'rails_admin_list_scope.rb')
require Rails.root.join('lib', 'rails_admin_refund_money.rb')
require Rails.root.join('lib', 'rails_admin_dispute_link.rb')

RailsAdmin.config do |config|
module RailsAdmin
  module Config
    module Actions
      class SendBroadcastEmail < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
      end
      class AddToMailchimpList < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
      end
      class RefundMoney < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
      end
      class DisputeLink < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
      end
    end
  end
end

  config.current_user_method { current_person } #auto-generated
  config.authorize_with :cancan
  config.attr_accessible_role {:admin}
  config.authenticate_with {
    unless current_person
      session[:return_to] = request.url
      redirect_to '/login', :notice => "You must first log in or sign up before accessing this page."
    end
  }

  config.actions do
    dashboard
    index
    new
    send_broadcast_email
    add_to_mailchimp_list
    refund_money
    dispute_link
    show
    edit
    delete
    export
  end

  config.included_models = [
    Account,
    AccountDeactivated,
    AccountImport,
    ActivityStatus,
    Address,
    BroadcastEmail,
    BusinessType,
    Category,
    Charge,
    ExchangeAndFee,
    ExchangeDeleted,
    FeePlan,
    FeedPost,
    FixedTransactionFee,
    FixedTransactionStripeFee,
    FormSignupField,
    ForumPost,
    Message,
    Neighborhood,
    Offer,
    PercentTransactionFee,
    PercentTransactionStripeFee,
    Person,
    PersonDeactivated,
    PersonMetadatum,
    Preference,
    RecurringFee,
    RecurringStripeFee,
    Report,
    OfferReport,
    ReqReport,
    Req,
    State,
    SystemMessageTemplate,
    TimeZone,
  ]

  config.default_items_per_page = 100

  config.model State do
    visible false
  end

  config.model Address do
    visible false
    configure :person, :belongs_to_association
    object_label_method do
      :address_line_1
    end

    list do
      field :address_line_1
      field :city
      field :zipcode_plus_4
    end

    edit do
      field :address_line_1
      field :address_line_2
      field :address_line_3
      field :city
      field :state
      field :zipcode_plus_4
      field :address_privacy do
        label "Public"
      end
      field :primary
    end
  end

  config.model Account do
    list do
      scope do
        joins(:person).where( people: { deactivated:false } )
      end

      field :person do
        label "Name"
        searchable ['people.name', 'people.business_name', 'people.legal_business_name']
        queryable true
      end
      field :offset do
        label "Starting Balance"
      end
      field :balance do
        formatted_value do
          (bindings[:object].balance_with_initial_offset).to_s
        end
        sortable "accounts.balance + accounts.offset"
        sort_reverse true
      end
      field :credit_limit
      field :updated_at do
        label "Last Transaction"
      end
    end

    edit do
      field :name
      field :person do
        label "Name"
      end
      field :offset do
        label "Starting Balance"
      end
      field :balance do
        formatted_value do
          (bindings[:object].balance_with_initial_offset).to_s
        end
      end
      field :credit_limit
    end

    export do
      field :person
      field :offset do
        label "Starting Balance"
      end
      field :balance do
        formatted_value do
          (bindings[:object].balance_with_initial_offset).to_s
        end
      end
      field :credit_limit
      field :updated_at do
        label "Last Transaction"
      end
    end
  end

  config.model AccountImport do
    parent Account 
    list do
      field :person do
        label "Uploaded by"
        searchable [{Person => :name}]
        queryable true
      end
      field :successful
      field :created_at do
        label "Uploaded at"
      end
      field :file
    end

    show do
      field :name
      field :successful
      field :created_at do
        label "Uploaded at"
      end
      field :file
    end

    edit do
      field :person, :hidden do
        visible false
        # default_value do
        #   bindings[:view].current_person.id
        # end
      end
      field :file, :file_upload do
        label 'CSV File'
        help ''
        partial "import_file"
      end
    end
  end

  config.model AccountDeactivated do
    label do
      'Deactivated account'
    end
    list do
      scope do
        joins(:person).where( people: { deactivated:true } )
      end
      field :person do
        label "Name"
      end
      field :offset do
        label "Starting Balance"
      end
      field :balance do
        formatted_value do
          (bindings[:object].balance_with_initial_offset).to_s
        end
        sortable "accounts.balance + accounts.offset"
        sort_reverse true
      end
      field :credit_limit
      field :updated_at do
        label "Last Transaction"
      end
    end

    edit do
      field :name
      field :person do
        label "Name"
      end
      field :offset do
        label "Starting Balance"
      end
      field :balance do
        formatted_value do
          (bindings[:object].balance_with_initial_offset).to_s
        end
      end
      field :credit_limit
    end

    export do
      field :person
      field :offset do
        label "Starting Balance"
      end
      field :balance do
        formatted_value do
          (bindings[:object].balance_with_initial_offset).to_s
        end
      end
      field :credit_limit
      field :updated_at do
        label "Last Transaction"
      end
    end
  end

  config.model Req do
    label "Request"
    label_plural "Requests"
    list do
      field :name
      field :person do
        label "Requested by"
      end
      field :created_at
    end

    edit do
      field :group
      field :person do
        label "Requested by"
      end
      field :name
      field :estimated_hours
      field :due_date, :date
      field :description
      field :categories
      field :neighborhoods
    end
  end

  config.model Offer do
    list do
      field :name
      field :person do
        label "Offered by"
      end
      field :created_at
    end

    edit do
      field :group
      field :person do
        label "Offered by"
      end
      field :name
      field :total_available
      field :price
      field :expiration_date, :date
      field :description
      field :categories
      field :neighborhoods
    end
  end

  config.model Preference do
    configure :default_profile_picture do
      pretty_value do
        %{<a href="/photos/default_profile_picture" target="_blank">Change default profile image</a>}
      end
    end

    configure :default_group_picture do
      pretty_value do
        %{<a href="/photos/default_group_picture" target="_blank">Change default group image</a>}
      end
    end

    list do
      field :app_name
    end

    edit do
      group :default do
        help "*** Some preferences require server restart to take effect after change ***"
      end
      field :app_name
      field :server_name
      field :groups
      field :alt_signup_link
      field :default_group_id do
        properties[:collection] = Group.all.map {|g| [g.name,g.id]}
        partial "select"
      end
      field :locale do
        properties[:collection] = [['English','en'],['Spanish','es'],['French','fr'],['Greek','gr']]
        partial "select"
      end
      field :logout_url
      field :blog_feed_url
      field :new_member_notification
      field :googlemap_api_key
      field :gmail
      field :email_notifications
      field :email_verifications
      field :protected_categories
      field :whitelist
      field :openid
      field :public_uploads
      field :public_private_bid do
        label "Public/Private Bids"
      end
      field :mailchimp_list_id do
        label "Mailchimp List ID"
      end
      field :mailchimp_send_welcome
      field :registration_intro
      field :agreement
      field :about
      field :practice
      field :steps
      field :questions
      field :contact
      field :analytics
      field :display_orgicon
      field :default_profile_picture
      field :default_group_picture
      field :default_deactivated_fee_plan_id do
        properties[:collection] = FeePlan.all.map {|g| [g.name,g.id]}
        partial "select"
      end
      field :show_description
      field :show_neighborhood
    end
  end

  config.model ExchangeAndFee do
    list do
      scope do
        joins(:customer, :worker)
      end

      field :created_at do
        label "Date"
        formatted_value do
          value.strftime('%m/%d/%Y')
        end
      end

      field :time do
        label "Time"
        formatted_value do
          bindings[:object].created_at.strftime('%H:%M')
        end
      end
      field :customer do
        queryable true
        searchable :display_name
      end
      field :worker do
        queryable true
        searchable :display_name
      end
      field :amount
      field :notes do
        label "Memo"
        formatted_value do
          bindings[:object].memo
        end
      end
    end

    edit do
      field :created_at do
        label 'Date'
        required :true
      end
      field :worker do
        label "Credits in"
        required :true
      end
      field :customer do
        label "Credits out"
        required :true
      end
      field :amount
      field :group_id, :enum do
        label "Unit"
        required :true
        enum_method do
          :group_id_enum
        end
      end
      field :notes, :text
      field :wave_all_fees
      #field :metadata
    end
  end

  config.model ExchangeDeleted do
    label do
      'Deleted exchange'
    end
    list do
      scope do
        only_deleted
      end
      field :created_at
      field :customer do
        searchable [{Person => :name}]
        queryable true
      end
      field :worker do
        searchable :workers_exchanges => :name
        queryable true
      end
      field :amount
      field :notes do
        label "Memo"
        formatted_value do
          bindings[:object].memo
        end
      end
    end
  end

  config.model FeedPost do
    list do
      field :title
      field :date_published
      field :created_at
      field :updated_at
    end

    edit do
      field :title
      field :content, :text do
        #ckeditor true
      end
    end
  end

  config.model ForumPost do
    list do
      field :person
      field :body
      field :created_at
    end

    edit do
      field :body
    end
  end

  config.model BroadcastEmail do
    edit do
      field :subject
      field :message, :text do
        #ckeditor true
      end
    end
  end

  config.model Category do
    list do
      field :name
    end

    edit do
      field :name
      field :parent_id do
        properties[:collection] = [['',nil]] + Category.by_long_name.map {|c| [c.long_name, c.id]}
        partial "select"
      end
      field :description
    end
  end

  config.model Neighborhood do
    list do
      field :name
    end

    edit do
      field :name
      field :parent_id do
        properties[:collection] = [['',nil]] + Neighborhood.by_long_name.map {|n| [n.long_name, n.id]}
        partial "select"
      end
      field :description
    end
  end

  config.model BusinessType do
    list do
      field :name
      sort_by :name
    end

    edit do
      field :name
      field :description
    end
  end

  config.model ActivityStatus do
    list do
      field :name
      sort_by :name
    end

    edit do
      field :name
      field :description
    end
  end

  config.model FeePlan do
    list do
      field :name
      field :description
      sort_by :name
    end
    edit do
      exclude_fields :people
      field :fixed_transaction_stripe_fees do
        label "Fixed transaction cash fees"
      end
      field :percent_transaction_stripe_fees do
        label "Percent transaction cash fees"
      end
      field :recurring_stripe_fees do
        label "Recurring cash fees"
      end
      field :fixed_transaction_fees
      field :percent_transaction_fees
      field :recurring_fees
      field :available

  end

  config.model FixedTransactionStripeFee do
    label "Fixed transaction cash fee"
    field :amount
    field :fee_plan
  end

  config.model PercentTransactionStripeFee do
    label "Percent transaction cash fee"
    field :percent do
      pretty_value do
        (bindings[:object].percent * 100).to_s
      end
    end
    field :fee_plan
  end

  config.model RecurringStripeFee do
    label "Recurring cash fee"
    field :amount
    field :interval, :enum do
      enum do
        ['month','year']
      end
    end
    field :fee_plan
    list do
      field :plan
    end
  end

  config.model FixedTransactionFee do
    field :amount
    field :recipient
    field :fee_plan
  end

  config.model PercentTransactionFee do
    field :display_percent do
      label "Percent"
    end
    field :recipient
    field :fee_plan
  end

  config.model RecurringFee do
    field :amount
    field :interval, :enum do
      enum do
        ['month','year']
      end
    end
    field :recipient
    field :fee_plan
  end


  config.model Charge do
    label 'Charges'
    list do
      scope do
        joins(:person).where( people: { deactivated:false} )
      end

      field :person do
        label "Billed person"
        searchable [{Person => :email}]
        queryable true
      end
      field :amount
      field :description
      field :status do
        label "State"
      end
      field :created_at do
        label "Date"
      end
    end

  end

  end

  config.model Person do
    object_label_method do
      :display_name
    end

    list do
      sort_by :display_name
      scope do
        where deactivated: false
      end
      field :last_logged_in_at do
        label "Last login"
      end
      field :name
      field :business_name
      field :email
      field :deactivated do
        label "Disabled"
      end
      field :email_verified
      field :requires_credit_card
      field :phone
      field :admin
      field :junior_admin
      field :org
      field :fee_plan
      field :stripe_id
      field :mailchimp_subscribed
      field :openid_identifier
      sort_by :last_logged_in_at
    end

    export do
      field :last_logged_in_at do
        label "Last login"
      end
      field :name
      field :email
      field :deactivated do
        label "Disabled"
      end
      field :email_verified
      field :requires_credit_card
      field :phone
      field :admin
      field :org
      field :web_site_url
      field :org
      field :title
      field :business_name
      field :legal_business_name
      field :business_type
      field :activity_status
      field :fee_plan
      field :support_contact
    end

    edit do
      field :person_metadata
      field :name
      field :email
      field :password
      field :password_confirmation
      field :deactivated
      field :visible do
        label "Listed in Directory"
      end
      field :email_verified
      field :requires_credit_card
      field :update_card
      field :phone
      field :phoneprivacy do
        label "Share Phone?"
      end
      field :admin
      field :junior_admin
      field :web_site_url
      field :org
      field :title
      field :business_name
      field :legal_business_name
      field :business_type
      field :activity_status
      field :fee_plan
      field :support_contact
      field :description, :text do
        #ckeditor true
      end
      field :addresses
      # generally not appropriate for admin to edit openid since it is an assertion
    end
  end

  config.model PersonDeactivated do
    object_label_method do
      :display_name
    end
    label do
      'Deactivated people'
    end
    list do
      scope do
        where deactivated: true
      end
      field :last_logged_in_at do
        label "Last login"
      end
      field :name
      field :business_name
      field :email
      field :deactivated do
        label "Disabled"
      end
      field :email_verified
      field :requires_credit_card
      field :phone
      field :admin
      field :org
      field :fee_plan
      field :stripe_id
      field :openid_identifier
      sort_by :last_logged_in_at
    end

    edit do
      field :name
      field :email
      field :password
      field :password_confirmation
      field :deactivated
      field :email_verified
      field :requires_credit_card
      field :phone
      field :phoneprivacy do
        label "Share Phone?"
      end
      field :admin
      field :web_site_url
      field :org
      field :title
      field :business_name
      field :legal_business_name
      field :business_type
      field :activity_status
      field :fee_plan
      field :support_contact
      field :description, :text do
        #ckeditor true
      end
      field :addresses
      # generally not appropriate for admin to edit openid since it is an assertion
    end
  end

  config.model TimeZone do
    label "Time Zone"
    label_plural "Time Zone"
    field :time_zone, :enum do
      enum do
        ActiveSupport::TimeZone.zones_map.map {|x|[x[1], x[0]]}
      end
    end
    field :date_style, :enum do
      enum do
        TimeZone::Date_Style.keys
      end
    end
  end

  config.model PersonMetadatum do
    field :id
    field :key
    field :value
    field :person_id
  end

  config.model SystemMessageTemplate do
    label "Form"
    label_plural "Forms"

    list do
      field :title
      field :text
      field :message_type
      field :lang
    end

    edit do
      field :title, :text
      field :text, :text
      field :message_type do
        properties[:collection] = SystemMessageTemplate.select(:message_type).uniq.all.map {|x| x.message_type}
        partial "select"
      end
      field :lang do
        properties[:collection] = I18n.available_locales.map {|x| x.to_s}
        partial 'select'
      end
    end

  end

  config.model Message do
    label "Message"
    label_plural "Messages"

    list do
      field :id
      field :subject
      field :content
      field :sender do
        pretty_value do
          bindings[:object].sender_id.blank? ? "[system]" : bindings[:object].sender.display_name
        end
      end
      field :recipient
      field :sender_deleted_at
    end
  end

  config.model 'Report' do
    label 'Report'
    label_plural 'Reports'

    list do
      scope do
        joins(:person).where( people: { deactivated:false } )
      end
      field :id
      field :record
    end
  end

  config.model 'OfferReport' do
    parent Report
    
    label 'Report'
    label_plural 'Reports'

    list do
      scope do
        joins(:person).where( people: { deactivated:false } )
      end
      field :id
      field :record
    end
  end

end

end
