ActionController::Routing::Routes.draw do |map|
  map.resources :broadcast_emails

  map.resources :bids

  map.resources :reqs do |req|
    req.resources :bids
  end

  map.resources :categories

  map.resources :events, :member => { :attend => :get, 
                                      :unattend => :get } do |event|
    event.resources :comments
  end

  map.resources :preferences
  map.resources :searches
  map.resources :activities
  map.resources :connections
  map.resources :password_reminders
  map.resources :photos
  map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.resource :session
  map.resources :messages, :collection => { :sent => :get, :trash => :get },
                           :member => { :reply => :get, :undestroy => :put }

  map.resources :people, :member => { :verify_email => :get,
                                      :common_contacts => :get }
  map.connect 'people/verify/:id', :controller => 'people',
                                    :action => 'verify_email'
  map.resources :people do |person|
     person.resources :messages
     person.resources :photos
     person.resources :connections
     person.resources :comments
  end
  map.namespace :admin do |admin|
    admin.resources :people, :active_scaffold => true
    admin.resources :preferences, :broadcast_emails
    admin.resources :forums do |forums|
      forums.resources :topics do |topic|
        topic.resources :posts
      end
    end    
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
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  #map.home '/', :controller => 'home'
  map.home '/', :controller => 'blogs', :action => 'show', :id => 1
  map.about '/about', :controller => 'home', :action => 'about'
  map.practice '/practice', :controller => 'home', :action => 'practice'
  map.steps '/steps', :controller => 'home', :action => 'steps'
  map.questions '/questions', :controller => 'home', :action => 'questions'
  map.memberships '/memberships', :controller => 'home', :action => 'memberships'
  map.contact '/contact', :controller => 'home', :action => 'contact'

  map.admin_home '/admin/home', :controller => 'home'

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
  map.root :controller => "home"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
