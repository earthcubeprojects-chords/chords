Rails.application.routes.draw do

  devise_for :users
  resources :vars

  get 'about/data_urls'          => 'about#data_urls'
  get 'sites/geo'                => 'sites#geo'
  get 'monitor/live'             => 'monitor#live'

  get 'instruments/live'         => 'instruments#live'
  get 'instruments/simulator'    => 'instruments#simulator'
  get 'instruments/duplicate'    => 'instruments#duplicate'

  get 'measurements/url_create'  => 'measurements#url_create'
  get 'measurements/delete_test' => 'measurements#delete_test'

  resources :profiles, only: [:index, :create]
  resources :about
  resources :dashboard
  resources :urlbuilder
  resources :datafetch
  resources :monitor
  resources :measurements
  resources :instruments
  resources :sites
  root 'dashboard#index'

  resources :instruments do
    member do
      get 'live'
    end
  end

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
