Lawdingo::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  resources :users do
    put 'image_upload'
    get 'chat_session'
    get 'onlinestatus'
  end

  resources :sessions
  resources :conversations do
    get 'review'
    get 'summary'
  end

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
  namespace :admin do
    #     # Directs /admin/products/* to Admin::ProductsController
    #     # (app/controllers/admin/products_controller.rb)
    resources :clients
    resources :lawyers do
      get 'account_approval'
    end
    resources :clsessions
    resources :pages
  end

  match 'modparam' =>'users#update_parameter', :as =>:update_parameter
  match '/user/sessions/:user_id' =>"users#session_history", :as =>:user_session_history


  match '/about' =>"pages#show", :name =>'about', :as =>:about_page
  match '/about_attorneys' =>"pages#about_attorneys", :name =>'about_attorneys', :as =>:about_attorneys
  match '/terms' =>"pages#terms_of_use", :name =>'terms', :as =>:terms_page
  match '/login' => "sessions#new", :as => :login
  match '/logout' => "sessions#destroy", :as => :logout
  match '/details' => 'users#payment_info', :as => :card_detail
  match '/welcome' => 'users#welcome_lawyer', :as => :welcome
  match '/Register' => 'users#register_for_videochat', :as => :register_videochat
  match '/find_friend' => 'users#find_remote_user_for_videochat', :as => :find_remote_user
  match '/UpdateBusyStatus' => 'users#update_busy_status', :as => :UpdateBusyStatus
  match '/ScheduleSession' => 'users#send_email_to_lawyer', :as => :schedule_session
  match '/UpdateOnlineStatus' => 'users#update_online_status', :as => :UpdateOnlineStatus
  match '/search/populate_specialities' => 'search#populate_specialities'
  match '/search/filter_results' => 'search#filter_results'
  match '/upatePaymentInfo' => 'users#update_payment_info'
  match '/CheckPaymentInfo' => 'users#has_payment_info'

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  match '/admin' =>"users#show", :as =>:admin_home
  root :to => 'users#home'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

