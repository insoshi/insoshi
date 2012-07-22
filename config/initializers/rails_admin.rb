unless Rails.env == 'test'
RailsAdmin.config do |config|

  config.current_user_method { current_person } #auto-generated
  config.authorize_with :cancan
  config.attr_accessible_role {:admin}
  config.authenticate_with {
    unless current_person
      session[:return_to] = request.url
      redirect_to login_url, :alert => "You must first log in or sign up before accessing this page."
    end
  }

  config.included_models = [Preference,Exchange,ForumPost,FeedPost,BroadcastEmail,Person,Category,Neighborhood]

  config.model Preference do
    list do
      field :app_name
    end

    edit do
      field :app_name
      field :domain
      field :server_name
      field :smtp_server
      field :smtp_port do
        properties[:collection] = [['587','587'],['25','25']]
        partial "select"
      end
      field :default_group_id do
        properties[:collection] = Group.all.map {|g| [g.name,g.id]}
        partial "select"
      end
      field :blog_feed_url
      field :exception_notification
      field :new_member_notification
      field :googlemap_api_key
      field :disqus_shortname
      field :gmail
      field :email_notifications
      field :email_verifications
      field :zipcode_browsing
      field :whitelist
      field :registration_intro
      field :agreement
      field :about
      field :practice
      field :steps
      field :questions
      field :contact
      field :analytics
    end
  end

  config.model Exchange do
    list do
      field :created_at
      field :customer do
        label "payer"
        formatted_value do
          value.name
        end
      end
      field :worker do
        label "payee"
        formatted_value do
          value.name
        end
      end
      field :amount
      field :metadata do
        label "memo"
        formatted_value do
          value.name
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
      field :person do
        formatted_value do
          value.name
        end
      end
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
      field :description
    end
  end

  config.model Neighborhood do
    list do
      field :name
    end

    edit do
      field :name
      field :description
    end
  end

  config.model Person do
    list do
      field :last_logged_in_at do
        label "last login"
      end
      field :name
      field :email
      field :deactivated do
        label "disabled"
      end
      field :email_verified
      field :phone
      field :admin
      field :org
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
      field :phone
      field :admin
      field :org
      field :description, :text do
        #ckeditor true
      end
      # generally not appropriate for admin to edit openid since it is an assertion
    end
  end
end

end
