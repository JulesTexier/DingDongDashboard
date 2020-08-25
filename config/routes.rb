require "sidekiq/web"

Rails.application.routes.draw do
  
  #############
  # 1 - Admin
  #############
  # ROOT
  root "static#home"
  
  # Rails admin
  mount RailsAdmin::Engine => "/admin", as: "rails_admin"
  devise_for :admins
  
  # Sidekiq 
  authenticate :admin do
    mount Sidekiq::Web => "/sidekiq"
  end
  
  #############
  # 2 - Core
  #############
  resources :subscribers, only: [:create, :update, :edit] do 
    get '/activation/' => 'subscribers#activation'
    get '/agglomeration' => 'subscribers#select_agglomeration'
  end
  resources :properties, only: [:show]

  #############
  # 3 - Hunters
  #############
  devise_for :hunters
  get 'selections/index'
  get 'selections/create'
  get 'selections/destroy'
  
  resources :hunters do
    resources :researches, only: [:index, :show, :create, :new, :edit, :update, :put, :patch, :destroy], controller: 'hunter_searches' do 
      resources :selections, only: [:index, :create, :destroy]
      resources :saved_properties, only: [:index, :create, :destroy]
    end
  end
  
  #############
  # 4 - Dashboard
  #############
  get "/dashboard/" => "static_pages#dashboard"
  get "/dashboard/properties" => "static_pages#properties"
  get "/dashboard/stats" => "static_pages#stats"
  get "/dashboard/chart" => "static_pages#chart"
  get "/dashboard/price" => "static_pages#property_price"
  get "/dashboard/source" => "static_pages#sources"
  get "/dashboard/duplicates" => "static_pages#duplicates"

  #############
  # 5 - API
  #############
  namespace "api" do
    namespace "v1" do

      # Subscribers
      get "/subscribers/fb/:facebook_id" => "subscribers#show_facebook_id"
      post "/subscribers/fb/:facebook_id" => "subscribers#create_from_facebook_id"
      resources :subscribers do
        get "/get/props/last/:x/days" => "subscribers#props_x_days"
      end

      # Other models
      resources :properties, only: [:show, :index]
      resources :brokers, only: [:show]
      resources :saved_properties, only: [:create, :destroy]

      # Manychat 
      post "/manychat/s/:subscriber_id/update" => "manychat#update_subscriber" # a garder
      get "/manychat/s/:subscriber_id/send/props/morning" => "manychat#send_props_morning" # a garder
      get "/manychat/s/:subscriber_id/send/props/favorites" => "manychat#send_props_favorites" # a UPDATE
      get "/manychat/s/:subscriber_id/send/last/:x/props" => "manychat#send_x_last_props" # a garder
      post "/manychat/s/:subscriber_id/add_status" => "manychat#create_subscriber_status" # a garder
      post "/manychat/s/:subscriber_id/send_to_broker" => "manychat#send_to_broker" # a garder
      get "/manychat/s/:subscriber_id/send/props/:property_id/details" => "manychat#send_prop_details" # a garder + ajouter le tracking
      get "/manychat/s/:subscriber_id/send/props/last/:x/days" => "manychat#send_props_x_days" # a checker
      
      # Trello
      post "/trello/add_action" => "trello#add_action_to_broker" #a garder

      # Webhooks 
      post "webhooks/postmark/inbound" => "webhooks#handle_postmark_inbound"
      post "webhooks/postmark/growth-new-contact" => "webhooks#handle_postmark_new_contact"

      #data
      get "data/subscribers" => "data#get_subscribers"
      get "data/subscribers/active" => "data#get_active_subscribers"
      get "data/subscribers/facebook" => "data#get_facebook_id_subscribers"
    end
  end
end
