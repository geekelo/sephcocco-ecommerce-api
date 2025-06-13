Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "signup" => "registration#create"
      post "login" => "authentication#create"
      resources :password_resets, only: [ :create, :update ] do
        collection do
          post "verify_otp" => "password_resets#verify_otp"
        end
      end

      # LOUNGE
      namespace :lounge do
        resources :sephcocco_lounge_products do
          member do
            post "like" => "sephcocco_lounge_products#like"
            post "unlike" => "sephcocco_lounge_products#unlike"
            post "switch_visibility" => "sephcocco_lounge_products#switch_visibility"
          end
        end
        resources :sephcocco_lounge_product_categories do
          # Custom route for adding a product to a category
          post :add_product_to_category, on: :collection
        end
        resources :sephcocco_lounge_product_likes
        resources :sephcocco_lounge_orders
        resources :sephcocco_lounge_payments
      end

      # PHARMACY
      namespace :pharmacy do
        resources :sephcocco_pharmacy_products do
          member do
            post "like" => "sephcocco_pharmacy_products#like"
            post "unlike" => "sephcocco_pharmacy_products#unlike"
            post "switch_visibility" => "sephcocco_pharmacy_products#switch_visibility"
          end
        end
        resources :sephcocco_pharmacy_product_categories do
          # Custom route for adding a product to a category
          post :add_product_to_category, on: :collection
        end
        resources :sephcocco_pharmacy_product_likes
        resources :sephcocco_pharmacy_orders
        resources :sephcocco_pharmacy_payments
        resources :sephcocco_pharmacy_faqs do
          member do
            post "like" => "sephcocco_pharmacy_faqs#like"
          end
        end
        resources :sephcocco_pharmacy_faq_categories
      end

      # RESTAURANT
      namespace :restaurant do
        resources :sephcocco_restaurant_products do
          member do
            post "like" => "sephcocco_restaurant_products#like"
            post "unlike" => "sephcocco_restaurant_products#unlike"
            post "switch_visibility" => "sephcocco_restaurant_products#switch_visibility"
          end
        end
        resources :sephcocco_restaurant_product_categories do
          # Custom route for adding a product to a category
          post :add_product_to_category, on: :collection
        end
        resources :sephcocco_restaurant_product_likes
        resources :sephcocco_restaurant_orders
        resources :sephcocco_restaurant_payments
        resources :sephcocco_restaurant_faqs do
          member do
            post "like" => "sephcocco_restaurant_faqs#like"
          end
        end
        resources :sephcocco_restaurant_faq_categories
      end
    end
  end

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
