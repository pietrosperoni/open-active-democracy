OpenActiveDemocracy::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  match '/priorites/flag/:id', :controller=>'priorities', :action=>'flag'
  match '/priorites/abusive/:id', :controller=>'priorities', :action=>'abusive'
  match '/priorites/not_abusive/:id', :controller=>'priorities', :action=>'not_abusive'

  match '/points/flag/:id', :controller=>'questions', :action=>'flag'
  match '/documents/flag/:id', :controller=>'documents', :action=>'flag'

  match '/admin/all_flagged', :controller=>'admin', :action=>'all_flagged'
  match '/admin/all_deleted', :controller=>'admin', :action=>'all_deleted'
  match '/users/list_suspended', :controller=>'users', :action=>'list_suspended'

  resources :partners, :member => {
    :email => :get,    
    :picture => :get,
    :picture_save => :post
  }
  resources :users, :has_one => [:password, :profile], :collection => {:endorsements => :get, :order => :post}, :member => {
    :suspend => :put,
    :unsuspend => :put,
    :activities => :get,
    :comments => :get,
    :points => :get,
    :discussions => :get,
    :capital => :get,
    :impersonate => :put,
    :followers => :get,
    :documents => :get,
    :stratml => :get,
    :ignorers => :get,
    :following => :get,
    :ignoring => :get,
    :follow => :post,
    :unfollow => :post,
    :make_admin => :put,
    :ads => :get,
    :priorities => :get,
    :signups => :get,
    :legislators => :get,
    :legislators_save => :post,
    :endorse => :post,
    :reset_password => :get,
    :resend_activation => :get } do |users|
     users.resources :messages
     users.resources :followings, :collection => { :multiple => :put }
     users.resources :contacts, :controller => :user_contacts, :as => "contacts", :collection => {
       :multiple => :put, 
       :following => :get,
       :members => :get,
       :not_invited => :get,
       :invited => :get
    }
  end
  
  resources :settings, :collection => {
    :signups => :get,    
    :picture => :get,
    :picture_save => :post,
    :legislators => :get,
    :legislators_save => :post,
    :branch_change => :get,
    :delete => :get 
  }
  
  resources :priorities, 
    :member => { 
      :flag_inappropriate => :put, 
      :bury => :put, 
      :compromised => :put, 
      :successful => :put, 
      :failed => :put, 
      :intheworks => :put, 
      :endorse => :post, 
      :endorsed => :get, 
      :opposed => :get,
      :activities => :get, 
      :endorsers => :get, 
      :opposers => :get, 
      :discussions => :get, 
      :create_short_url => :put,
      :tag => :post, 
      :tag_save => :put, 
      :points => :get, 
      :opposer_points => :get, :endorser_points => :get, :neutral_points => :get, :everyone_points => :get,
      :top_points => :get, :endorsed_points => :get, :opposed_top_points=> :get, :endorsed_top_points => :get,
      :opposer_documents => :get, :endorser_documents => :get, :neutral_documents => :get, :everyone_documents => :get,      
      :comments => :get, 
      :documents => :get },
    :collection => { 
      :yours => :get, 
      :yours_finished => :get, 
      :yours_top => :get,
      :yours_ads => :get,
      :yours_lowest => :get,      
      :yours_created => :get,
      :network => :get, 
      :consider => :get, 
      :obama => :get, :not_obama => :get, :obama_opposed => :get,      
      :finished => :get, 
      :ads => :get,
      :top => :get, 
      :rising => :get, 
      :falling => :get, 
      :controversial => :get, 
      :random => :get, 
      :newest => :get, 
      :untagged => :get } do |priorities|
      priorities.resources :changes, :member => { :start => :put, :stop => :put, :approve => :put, :flip => :put, :activities => :get } do |changes|
        changes.resources :votes
      end
      priorities.resources :points
      priorities.resources :documents
      priorities.resources :ads, :collection => {:preview => :post}, :member => {:skip => :post}
    end
  resources :activities, :member => { :undelete => :put, :unhide => :get } do |activities|
    activities.resources :followings, :controller => :following_discussions, :as => "followings"
    activities.resources :comments, 
      :collection => { :more => :get }, 
      :member => { :unhide => :get, :flag => :get, :not_abusive => :post, :abusive => :post }
  end 
  resources :points, 
    :member => { :activity => :get, 
        :discussions => :get, 
        :quality => :post, 
        :unquality => :post, 
        :unhide => :get },
    :collection => { :newest => :get, :revised => :get, :your_priorities => :get } do |points|
    points.resources :revisions, :member => {:clean => :get}
  end
  resources :documents, 
    :member => { :activity => :get, 
      :discussions => :get, :quality => :post, :unquality => :post, :unhide => :get },
    :collection => { :newest => :get, :revised => :get, :your_priorities => :get } do |documents|
    documents.resources :revisions, :controller => :document_revisions, :as => "revisions", 
      :member => {:clean => :get}
  end
  resources :legislators, :member => { :priorities => :get } do |legislators|
    legislators.resources :constituents, :collection => { :priorities => :get }
  end
  resources :blurbs, :collection => {:preview => :put}
  resources :email_templates, :collection => {:preview => :put}  
  resources :color_schemes, :collection => {:preview => :put}  
  resources :governments, :member => {:apis => :get}
  resources :widgets, :collection => {:priorities => :get, :discussions => :get, :points => :get, :preview_iframe => :get, :preview => :post}
  resources :bulletins, :member => {:add_inline => :post}
  resources :branches, :member => {:default => :post} do |branches|
    branches.resources :priorities, :controller => :branch_priorities, :as => "priorities", 
    :collection => { :top => :get, :rising => :get, :falling => :get, :controversial => :get, :random => :get, :newest => :get, :finished => :get}
    branches.resources :users, :controller => :branch_users, :as => "users",
    :collection => { :talkative => :get, :twitterers => :get, :newest => :get, :ambassadors => :get}
  end
  resources :searches, :collection => {:points => :get, :documents => :get}
  resources :signups, :endorsements, :passwords, :unsubscribes, :notifications, :pages, :about, :tags
  map.resource :session
  resources :delayed_jobs, :member => {:top => :get, :clear => :get}
  
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  resources :priority_processes
  resources :process_speech_master_videos
  resources :process_speech_videos
  resources :process_discussions
  resources :process_documents
  resources :process_types
  resources :process_document_elements
  resources :process_documents
  resources :process_document_types
  resources :process_document_states

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "priorities"

  # restful_authentication routes
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy' 
  map.unsubscribe '/unsubscribe', :controller => 'unsubscribes', :action => 'new'   

  # non restful routes
  match '/yours', :controller => 'priorities', :action => 'yours'
  match '/hot', :controller => 'priorities', :action => 'hot'
  match '/cold', :controller => 'priorities', :action => 'cold'
  match '/new', :controller => 'priorities', :action => 'new'        
  match '/controversial', :controller => 'priorities', :action => 'controversial'
   
  match '/vote/:action/:code', :controller => "vote"
  match '/splash', :controller => 'splash', :action => 'index'
  match '/issues', :controller => "issues"
  match '/issues.:format', :controller => "issues"
  match '/issues/:slug', :controller => "issues", :action => "show"
  match '/issues/:slug.:format', :controller => "issues", :action => "show"  
  match '/issues/:slug/:action', :controller => "issues"
  match '/issues/:slug/:action.:format', :controller => "issues"  

  match '/portal', :controller => 'portal', :action => 'index'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  match '/pictures/:short_name/:action/:id', :controller => "pictures"
  match ':controller'
  match ':controller/:action'  
  match ':controller/:action.:format' # this one is not needed for rails 2.3.2, and must be removed
  match ':controller/:action/:id'
  match ':controller/:action/:id.:format'
end
