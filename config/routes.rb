Rails.application.routes.draw do
  get 'hello_world', to: 'hello_world#index'
  namespace :admin do
    get "users/index"
    get "users/edit"
    get "users/update"
    get "dashboard/index"
  end
  devise_for :users
  # get "home/index"
  root to: "home#index"
  resources :inventory_logs, only: [ :new, :create, :index ]
  resources :products
  resources :inventory_logs, only: [ :new, :create ]
  resources :products do
  collection do
    post :import
  end
  end
  namespace :admin do
  get "dashboard", to: "dashboard#index"
  resources :users, only: [ :index, :edit, :update ]
  end

  get "reports", to: "reports#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
