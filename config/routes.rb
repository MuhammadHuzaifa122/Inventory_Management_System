Rails.application.routes.draw do
  devise_for :users
  # get "home/index"
  root to: "home#index"
  resources :products
  resources :inventory_logs, only: [ :new, :create ]
  get "up" => "rails/health#show", as: :rails_health_check
end
