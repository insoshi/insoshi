
Oscurrency::Application.routes.draw do
  resources :person_sessions
  resources :password_resets, :only => [:new, :create, :edit, :update]
  resources :member_preferences
  resources :neighborhoods
  resources :memberships do
    member do
      delete :unsuscribe
      post :suscribe
    end
  end

  resources :transacts
  resources :groups do
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
  resources :events do
    member do
      get :attend
      get :unattend
    end
    resources :comments
  end

  resources :preferences
  resources :searches
  resources :activities
  resources :connections
  resources :photos
  resources :messages do
    collection do
      get :sent
      get :trash
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
    resources :comments
  end

  match 'people/verify/:id' => 'people#verify_email'

  namespace :admin do
    resources :preferences
  end
  resources :blogs do
    resources :posts do
      resources :comments
    end
  end

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
  match '/oauth/request_token' => 'oauth#request_token', :as => :request_token
  match '/oauth/access_token' => 'oauth#access_token', :as => :access_token
  match '/oauth/test_request' => 'oauth#test_request', :as => :test_request
  match '/oauth' => 'oauth#index', :as => :oauth
  match '/home/show/:id' => 'home#show'
  root :to => 'home#index'
  match '/' => 'home#index', :as => :home
end
