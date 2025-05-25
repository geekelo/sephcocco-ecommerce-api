Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "signup" => "registration#create"
      post "login" => "authentication#create"

      resources :sephcocco_lounge_products do
        member do
          post "like" => "sephcocco_lounge_products#like"
          post "unlike" => "sephcocco_lounge_products#unlike"
          post "switch_visibility" => "sephcocco_lounge_products#switch_visibility"
        end
      end
      resources :sephcocco_lounge_product_categories do
        member do
          post "add_product_to_category" => "sephcocco_lounge_product_categories#add_product_to_category"
        end
      end
      resources :sephcocco_lounge_product_likes
      resources :sephcocco_lounge_orders
    end
  end

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
