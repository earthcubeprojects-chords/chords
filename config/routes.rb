Rails.application.routes.draw do


  resources :archives
  resources :archive_jobs

  resources :site_types

  root      'dashboard#index'

  get 'about/data_urls'          => 'about#data_urls'
  get 'sites/geo'                => 'sites#geo'

  get 'instruments/duplicate'    => 'instruments#duplicate'
  get 'instruments/live'         => 'instruments#live'
  get 'instruments/simulator'    => 'instruments#simulator'

  get  'measurements/url_create'  => 'measurements#url_create'
  post 'measurements/delete_test' => 'measurements#delete_test'
  post 'measurements/trim'        => 'measurements#trim'

  get 'monitor/live'              => 'monitor#live'

  get 'profiles/export_configuration'              => 'profiles#export_configuration'
  get 'profiles/import_configuration'              => 'profiles#import_configuration'
  post 'profiles/import_configuration'              => 'profiles#import_configuration'

  get 'profiles/export_influxdb'              => 'profiles#export_influxdb'
  get 'profiles/import_influxdb'              => 'profiles#import_influxdb'
  post 'profiles/import_influxdb'              => 'profiles#import_influxdb'

  post 'archive/push_cuahsi_variables' => 'archives#push_cuahsi_variables', as: :push_cuahsi_variables
  post 'archive/push_cuahsi_methods' => 'archives#push_cuahsi_methods', as: :push_cuahsi_methods
  post 'archive/push_cuahsi_sites' => 'archives#push_cuahsi_sites', as: :push_cuahsi_sites
  post 'archive/push_cuahsi_sources' => 'archives#push_cuahsi_sources', as: :push_cuahsi_sources


  post 'archives/update_credentials'  => 'archives#update_credentials'

  post 'archives/enable_archiving'    => 'archives#enable_archiving'
  post 'archives/disable_archiving'   => 'archives#disable_archiving'




  # devise_for :users
  devise_for :users, controllers: {
     sessions: 'users/sessions'
  }

  resources :instruments do
    member do
      get 'live'
    end
  end

  resources :vars do
    get :autocomplete_measured_property_label, :on => :collection
    get :autocomplete_unit_name, :on => :collection
  end

  resources :about
  resources :dashboard
  resources :data
  resources :instruments
  resources :measurements
  resources :measured_properties
  resources :monitor
  resources :profiles, only: [:index, :create, :backup, :restore]
  resources :sites
  resources :users
  resources :urlbuilder
  resources :vars
  resources :units
  resources :topic_categories
  resources :topic_categories
  resources :influxdb_tags
  resources :site_types

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
