ActionController::Routing::Routes.draw do |map|
  map.resources :comments
  
 
  map.resources :blogs do |blog|
    blog.resources :posts
  end

  map.resources :forums do |forum|
    forum.resources :topics do |topic|
      topic.resources :posts
    end
  end

  map.resources :connections

  map.resources :password_reminders
  map.resources :photos
  map.resource :session
  map.resources :messages, :collection => { :sent => :get, :trash => :get },
                           :member => { :reply => :get, :undestroy => :put }
  map.resources :people, :collection => { :search => :get }
  map.resources :people do |person|
     person.resources :messages
     person.resources :photos
     person.resources :connections
  end
  
  map.forum '/forum', :controller => 'topics', :action => 'index'
  # map.forum_topics '/forum/topics', :controller => 'topics'
  # map.forum_topic_posts '/forum/topics/:topic_id/posts',
  #                       :controller => 'posts', :action => 'index'
  # map.new_forum_topic '/forum/topic/new',
  #                       :controller => 'topics', :action => 'new'
  
  
  map.signup '/signup', :controller => 'people', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.home '/', :controller => 'home'

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
