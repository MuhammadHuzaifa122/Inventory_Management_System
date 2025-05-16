Rails.application.routes.draw do
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
  get "reports", to: "reports#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
