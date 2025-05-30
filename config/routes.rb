
Rails.application.routes.draw do
  namespace :admin do
    get "users/index"
    get "users/edit"
    get "users/update"
    get "dashboard/index"
  end
  # get "home/index"
  root to: "home#index"

  resources :inventory_logs, only: [ :new, :create, :index ]

  resources :inventory_logs, only: [ :new, :create ]

  resources :products do
    collection do
      get :search
      post :import
    end
  end

  namespace :admin do
    get "dashboard", to: "dashboard#index"
    resources :users, only: [ :index, :edit, :update ]
  end

  get "reports", to: "reports#index"
  get "reports/fetch", to: "reports#fetch"

  post "/create-checkout-session", to: "checkout#create"

  get "/payment/success", to: "payments#success", as: :payment_success

  get "products/payment_cancelled", to: "products#payment_cancelled"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  get "up" => "rails/health#show", as: :rails_health_check
end
