ActionController::Routing::Routes.draw do |map|
  map.resources :member_preferences

  map.resources :neighborhoods

  map.resources :memberships, :member => {:unsuscribe => :delete, :suscribe => :post}

  map.resources :transacts, :as => "transacts/:asset"

  map.resources :groups, :has_many => [:offers,:reqs], :shallow => true, 
    :member => { :join => :post, 
                 :leave => :post, 
                 :exchanges => :get,
                 :members => :get,
                 :graphs => :get,
                 :photos => :get,
                 :new_photo => :post,
                 :save_photo => :post,
                 :delete_photo => :delete } do |group|
    group.resources :memberships
    group.resource :forum
  end

  map.resources :broadcast_emails

  map.resources :bids

  map.resources :reqs, :member => {:deactivate => :post} do |req|
    req.resources :bids
  end

  map.resources :offers

  map.resources :categories

  map.resources :events, :member => { :attend => :get, 
                                      :unattend => :get } do |event|
    event.resources :comments
  end

  map.resources :preferences
  map.resources :searches
  map.resources :activities
  map.resources :connections
  map.resources :password_resets, :only => [:new,:create,:edit,:update]
  map.resources :photos
  #map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  #map.resource :session
  map.resources :person_sessions
  map.resources :messages, :collection => { :sent => :get, :trash => :get },
                           :member => { :reply => :get, :undestroy => :put }

  map.resources :people, :member => { :verify_email => :get,
                                      :su => :get,
                                      :common_contacts => :get }
  map.connect 'people/verify/:id', :controller => 'people',
                                    :action => 'verify_email'
  map.resources :people, :member => {:groups => :get, 
    :admin_groups => :get} do |person|
     person.resources :messages
     person.resources :accounts
     person.resources :exchanges
     person.resources :addresses
     person.resources :photos
     person.resources :connections
     person.resources :comments
  end
  map.namespace :admin do |admin|
    admin.resources :people, :active_scaffold => true
    admin.resources :categories, :active_scaffold => true
    admin.resources :neighborhoods, :active_scaffold => true
    admin.resources :exchanges, :active_scaffold => true
    admin.resources :preferences, :broadcast_emails, :feed_posts
  end
  map.resources :blogs do |blog|
    blog.resources :posts do |post|
        post.resources :comments
    end
  end

  map.resources :forums do |forums|
    forums.resources :topics do |topic|
      topic.resources :posts
    end
  end
  
  map.signup '/signup', :controller => 'people', :action => 'new'
  map.login '/login', :controller => 'person_sessions', :action => 'new'
  map.logout '/logout', :controller => 'person_sessions', :action => 'destroy'
  map.home '/', :controller => 'home'
  map.refreshblog '/refreshblog', :controller => 'feed_posts', :action => 'refresh_blog'
  map.about '/about', :controller => 'home', :action => 'about'
  map.practice '/practice', :controller => 'home', :action => 'practice'
  map.steps '/steps', :controller => 'home', :action => 'steps'
  map.questions '/questions', :controller => 'home', :action => 'questions'
  map.contact '/contact', :controller => 'home', :action => 'contact'
  map.agreement '/agreement', :controller => 'home', :action => 'agreement'

  map.admin_home '/admin/home', :controller => 'home'

  map.resources :oauth_clients
  map.authorize '/oauth/authorize', :controller => 'oauth', :action => 'authorize'
  map.request_token '/oauth/request_token', :controller => 'oauth', :action => 'request_token'
  map.access_token '/oauth/access_token', :controller => 'oauth', :action => 'access_token'
  map.test_request '/oauth/test_request', :controller => 'oauth', :action => 'test_request'
  map.oauth '/oauth', :controller => 'oauth', :action => 'index'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'home'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
