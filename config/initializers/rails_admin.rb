unless Rails.env == 'test'
RailsAdmin.config do |config|
  config.authorize_with :cancan
  config.authenticate_with {
    unless current_person
      session[:return_to] = request.url
      redirect_to login_url, :alert => "You must first log in or sign up before accessing this page."
    end
  }

  config.included_models = [Exchange,ForumPost,FeedPost,BroadcastEmail,Person]

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
        ckeditor true
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
        ckeditor true
      end
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
      field :deactivated
      field :email_verified
      field :phone
      field :admin
      field :org
      field :description, :text do
        ckeditor true
      end
      # generally not appropriate for admin to edit openid since it is an assertion
    end
  end
end

end
