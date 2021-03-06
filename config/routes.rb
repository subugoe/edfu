Rails.application.routes.draw do

  get 'errors/file_not_found'

  get 'errors/unprocessable'

  get 'errors/internal_server_error'

  get 'edfu_status/status'

  get 'edfu_log/status'

  devise_for :users
  # devise_for :admin_users, ActiveAdmin::Devise.config
  # ActiveAdmin.routes(self)

  #resources :uploads

  resources :stellen, only: [:index, :show]

  resources :wbsberlin, only: [:index, :show]

  resources :worte, only: [:index, :show]

  resources :goetter, only: [:index, :show]

  resources :orte, only: [:index, :show]

  resources :formulare, only: [:index, :show]

  resources :edfulogs, only: [:index, :show]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".


  #root 'uploads#new'

  authenticate do
    root 'uploads#new'
    get 'uploads/', to: 'uploads#new'
    post 'uploads/', to: 'uploads#create'
    get 'uploads/new/', to: 'uploads#new'
  end

  # match '/403', to: 'errors#not_authenticated', via: :all
  match '/404', to: 'errors#file_not_found', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

  # match '/403', to: 'uploads#new', via: :all
  # match '/404', to: 'uploads#new', via: :all
  # match '/422', to: 'uploads#new', via: :all
  # match '/500', to: 'uploads#new', via: :all

  #resources :uploads, only: [:new, :create]

  #get 'uploads/', to: 'uploads#new'
  #post 'uploads/', to: 'uploads#create'
  #
  #get 'uploads/new/', to: 'uploads#new'

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
