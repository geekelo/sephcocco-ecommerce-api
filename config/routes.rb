Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Mount Action Cable for WebSocket connections
  mount ActionCable.server => '/cable'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "signup" => "registration#create"
      post "login" => "authentication#create"

      # uploads to R2
      post :presign_uploads, to: "uploads#presign_multiple"
      post :save_metadata,  to: "uploads#save"
      post :presign_upload, to: "uploads#presign"
      
      resources :password_resets, only: [ :create, :update ] do
        collection do
          post "verify_otp" => "password_resets#verify_otp"
        end
      end

      resources :sephcocco_users, only: [ :index, :update ] do
        collection do
          patch "switch_user_role" => "sephcocco_users#switch_user_role"
          patch "suspend_user" => "sephcocco_users#suspend_user"
          patch "unsuspend_user" => "sephcocco_users#unsuspend_user"
          patch "update_user_outlets" => "sephcocco_users#update_user_outlets"
          get "get_riders" => "sephcocco_users#get_riders"
          get "check_email_confirmation" => "sephcocco_users#check_email_confirmation"
          post "request_email_confirmation_token" => "sephcocco_users#request_email_confirmation_token"
          patch "confirm_email" => "sephcocco_users#confirm_email"
          get "get_user_subroles" => "sephcocco_users#get_user_subroles"
          patch "soft_delete_user" => "sephcocco_users#soft_delete_user"
        end
      end

      # Rider location tracking
      resources :rider_locations, only: [ :index, :show ] do
        collection do
          post :update_location
          post :cleanup
        end
      end

      # LOUNGE
      namespace :lounge do
        resources :sephcocco_lounge_products do
          member do
            post "like" => "sephcocco_lounge_products#like"
            post "unlike" => "sephcocco_lounge_products#unlike"
            post "switch_visibility" => "sephcocco_lounge_products#switch_visibility"
            post "append_image" => "sephcocco_lounge_products#append_image"
            post "set_main_image" => "sephcocco_lounge_products#set_main_image"
            post "upload_image" => "sephcocco_lounge_products#upload_image"
          end
        end
        resources :sephcocco_lounge_product_categories do
          # Custom route for adding a product to a category
          post :add_product_to_category, on: :collection
        end
        resources :sephcocco_lounge_product_likes
        resources :sephcocco_lounge_orders do
          collection do
            get "pending" => "sephcocco_lounge_orders#pending_orders"
            get "completed" => "sephcocco_lounge_orders#completed_orders"
            get "paid" => "sephcocco_lounge_orders#paid_orders"
            get "delivering" => "sephcocco_lounge_orders#delivering_orders"
          end
        end
        resources :sephcocco_lounge_payments do
          collection do
            get :verify
            post :verify
          end
        end
        resources :sephcocco_lounge_shippings do
          member do
            patch :assign_rider
            patch :start_delivery
            patch :complete_delivery
            patch :cancel_delivery
          end
        end
        resources :sephcocco_lounge_faqs
        resources :sephcocco_lounge_admin_notifications, only: [ :index, :update ]
        resources :sephcocco_lounge_admin_activities, only: [ :index ]
        resources :sephcocco_lounge_messages do
          collection do
            get :get_messages
            get :user_threads
          end
        end
        resources :sephcocco_lounge_analytics, only: [ :index ] do
          collection do
            get :total_products
            get :total_payment_received
            get :total_orders
            get :total_unresolved_chats
            get :unresolved_chats
            get :monthly_payments
            get :monthly_orders
            get :yearly_payments
            get :yearly_orders
            get :overview_performance
          end
        end
        resources :sephcocco_lounge_stock_managements
      end

      # PHARMACY
      namespace :pharmacy do
        resources :sephcocco_pharmacy_products do
          member do
            post "like" => "sephcocco_pharmacy_products#like"
            post "unlike" => "sephcocco_pharmacy_products#unlike"
            post "switch_visibility" => "sephcocco_pharmacy_products#switch_visibility"
            post "append_image" => "sephcocco_pharmacy_products#append_image"
            post "set_main_image" => "sephcocco_pharmacy_products#set_main_image"
            post "upload_image" => "sephcocco_pharmacy_products#upload_image"
          end
        end
        resources :sephcocco_pharmacy_product_categories do
          # Custom route for adding a product to a category
          post :add_product_to_category, on: :collection
        end
        resources :sephcocco_pharmacy_product_likes
        resources :sephcocco_pharmacy_orders do
          collection do
            get "pending" => "sephcocco_pharmacy_orders#pending_orders"
            get "completed" => "sephcocco_pharmacy_orders#completed_orders"
            get "paid" => "sephcocco_pharmacy_orders#paid_orders"
            get "delivering" => "sephcocco_pharmacy_orders#delivering_orders"
          end
        end
        resources :sephcocco_pharmacy_payments do
          collection do
            get :verify
            post :verify
          end
        end
        resources :sephcocco_pharmacy_shippings do
          member do
            patch :assign_rider
            patch :start_delivery
            patch :complete_delivery
            patch :cancel_delivery
          end
        end
        resources :sephcocco_pharmacy_faqs
        resources :sephcocco_pharmacy_faq_categories
        resources :sephcocco_pharmacy_admin_notifications, only: [ :index, :update ]
        resources :sephcocco_pharmacy_admin_activities, only: [ :index ]
        resources :sephcocco_pharmacy_messages do
          collection do
            get :get_messages
            get :user_threads
          end
        end
        resources :sephcocco_pharmacy_analytics, only: [ :index ] do
          collection do
            get :total_products
            get :total_payment_received
            get :total_orders
            get :total_unresolved_chats
            get :unresolved_chats
            get :monthly_payments
            get :monthly_orders
            get :yearly_payments
            get :yearly_orders
            get :overview_performance
          end
        end
        resources :sephcocco_pharmacy_stock_managements
      end

      # RESTAURANT
      namespace :restaurant do
        resources :sephcocco_restaurant_products do
          member do
            post "like" => "sephcocco_restaurant_products#like"
            post "unlike" => "sephcocco_restaurant_products#unlike"
            post "switch_visibility" => "sephcocco_restaurant_products#switch_visibility"
            post "append_image" => "sephcocco_restaurant_products#append_image"
            post "set_main_image" => "sephcocco_restaurant_products#set_main_image"
            post "upload_image" => "sephcocco_restaurant_products#upload_image"
          end
        end
        resources :sephcocco_restaurant_product_categories do
          # Custom route for adding a product to a category
          post :add_product_to_category, on: :collection
        end
        resources :sephcocco_restaurant_product_likes
        resources :sephcocco_restaurant_orders do
          collection do
            get "pending" => "sephcocco_restaurant_orders#pending_orders"
            get "completed" => "sephcocco_restaurant_orders#completed_orders"
            get "paid" => "sephcocco_restaurant_orders#paid_orders"
            get "delivering" => "sephcocco_restaurant_orders#delivering_orders"
          end
        end

        resources :sephcocco_restaurant_payments do
          collection do
            get :verify
            post :verify
          end
        end
        resources :sephcocco_restaurant_shippings do
          member do
            patch :assign_rider
            patch :start_delivery
            patch :complete_delivery
            patch :cancel_delivery
          end
        end
        resources :sephcocco_restaurant_faqs
        resources :sephcocco_restaurant_faq_categories
        resources :sephcocco_restaurant_admin_notifications, only: [ :index, :update ]
        resources :sephcocco_restaurant_admin_activities, only: [ :index ]
        resources :sephcocco_restaurant_messages do
          collection do
            get :get_messages
            get :user_threads
          end
        end
        resources :sephcocco_restaurant_analytics, only: [ :index ] do
          collection do
            get :total_products
            get :total_payment_received
            get :total_orders
            get :total_unresolved_chats
            get :unresolved_chats
            get :monthly_payments
            get :monthly_orders
            get :yearly_payments
            get :yearly_orders
            get :overview_performance
          end
        end
        resources :sephcocco_restaurant_stock_managements
      end
    end
  end

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Route for serving images from R2
  get 'images/:key', to: 'images#show', as: :image

  # Defines the root path route ("/")
  # root "posts#index"
end
