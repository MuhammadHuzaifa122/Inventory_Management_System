Rails.application.routes.draw do
  # get "home/index"
  root to: "home#index"
  resources :inventory_logs, only: [ :new, :create, :index ]
  resources :products
  resources :inventory_logs, only: [ :new, :create ]
  get "up" => "rails/health#show", as: :rails_health_check
  devise_for :users
end
