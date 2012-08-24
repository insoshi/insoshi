
Oscurrency::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resources :person_sessions
  resources :password_resets, :only => [:new, :create, :edit, :update]
  resources :member_preferences
  resources :neighborhoods

  # XXX in 2.3.x, this was easier -> map.resources :transacts, :as => "transacts/:asset"
  get    "transacts(/:asset)(.:format)"          => "transacts#index",   :as => 'transacts'
  get    "transacts(/:asset)/new"      => "transacts#new",     :as => 'new_transact'
  get    "transacts(/:asset)/:id(.:format)"      => "transacts#show",    :as => 'transact'
  post   "transacts(/:asset)(.:format)"          => "transacts#create",  :as => 'transacts'
  #get    "transacts/[:asset]/:id/edit" => "transacts#edit",    :as => 'edit_transact'
  #put    "transacts/[:asset]/:id"      => "transacts#update",  :as => 'transact'
  delete "transacts(/:asset)/:id(.:format)"      => "transacts#destroy", :as => 'transact'

  resources :groups, :shallow => true do
    member do
      post :join
      post :leave
      get :exchanges
      get :members
      get :graphs
      get :photos
      post :new_photo
      post :save_photo
      delete :delete_photo
    end
    resources :memberships
    resources :reqs
    resources :offers
    resource :forum
  end

  resources :bids
  resources :reqs do
    member do 
      post :deactivate
    end
    resources :bids
  end

  resources :offers
  resources :categories

  resources :memberships do
    member do
      delete :unsuscribe
      post :suscribe
    end
  end

  resources :searches
  resources :activities
  resources :connections
  resources :photos
  resources :messages do
    collection do
      get :sent
      get :trash
      get :recipients
    end
    member do
      get :reply
      put :undestroy
    end
  end
  resources :people do
    member do
      get :verify_email
      get :su
      get :common_contacts
      get :groups
      get :admin_groups
    end
    resources :messages
    resources :accounts
    resources :exchanges
    resources :addresses
    resources :photos
    resources :connections
  end

  match 'people/verify/:id' => 'people#verify_email'

  resources :forums do
    resources :topics do
      resources :posts
    end
  end
  match '/signup' => 'people#new', :as => :signup
  match '/login' => 'person_sessions#new', :as => :login
  match '/logout' => 'person_sessions#destroy', :as => :logout
  match '/refreshblog' => 'feed_posts#refresh_blog', :as => :refreshblog
  match '/about' => 'home#about', :as => :about
  match '/practice' => 'home#practice', :as => :practice
  match '/steps' => 'home#steps', :as => :steps
  match '/questions' => 'home#questions', :as => :questions
  match '/contact' => 'home#contact', :as => :contact
  match '/agreement' => 'home#agreement', :as => :agreement
  resources :oauth_clients
  match '/oauth/authorize' => 'oauth#authorize', :as => :authorize
  match '/oauth/token' => 'oauth#token', :as => :token
  match '/oauth/request_token' => 'oauth#request_token', :as => :request_token
  match '/oauth/access_token' => 'oauth#access_token', :as => :access_token
  match '/oauth/test_request' => 'oauth#test_request', :as => :test_request
  match '/oauth/scopes' => 'transacts#scopes', :as => :scopes
  match '/oauth/revoke' => 'oauth#revoke', :as => :revoke
  match '/oauth' => 'oauth#index', :as => :oauth
  match '/about_user' => 'transacts#about_user', :as => :about_user
  match '/user_info' => 'transacts#user_info', :as => :user_info
  match '/wallet' => 'transacts#wallet', :as => :wallet
  match '/.well-known/host-meta' => 'home#host_meta', :as => :host_meta
  match '/home/show/:id' => 'home#show'
  root :to => 'home#index'
  match '/' => 'home#index', :as => :home
end
