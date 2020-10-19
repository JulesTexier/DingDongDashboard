require "sidekiq/web"

Rails.application.routes.draw do
  
  devise_for :brokers


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
  
  # Token confirmation email 
  get '/:token/confirm_email/', :to => "subscribers#confirm_email", as: 'confirm_email'
  
  # 404
  get :url_not_found, :to => "static#url_not_found", :path => 'lien-perdu'
  
  #############
  # 2 - Core
  #############
  resources :subscribers, only: [] do 
    get '/activation/' => 'subscribers#activation'
    get :professionals, :path => 'nos-pros'
    get :email_validation, :path => 'validez-votre-email'
    get :email_confirmed, :path => 'confirmation'
    get '/research/edit' => 'subscriber_researches#edit'
    patch '/research/update' => 'subscriber_researches#update'
    get '/research/stop' => 'subscriber_researches#stop'
    get '/research/activate' => 'subscriber_researches#activate'
    get '/mon-financement' => 'subscribers#contact_courtier'
    post '/financement-submit' => 'subscribers#contact_courtier_submit'
    get '/mon-financement-confirmation' => 'subscribers#contact_courtier_submitted'
  end 
  
  
  resources :properties, only: [:show]
  
  
  resource :subscriber_researches do
    get :step1, :path => 'agglomeration'
    get :step2, :path => 'criteres'
    get :step3, :path => 'profil'
    post :validate_step
  end
  
  # Broker custom client inscription path
  get '/inscription/courtier/:broker_id' => "subscribers#broker_onboarding"
  
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
  get "/dashboard/courtiers" => "static_pages#admin"
  
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
        get "/handle-onboarding" => "subscribers#handle_onboarding"
      end
      
      # Other models
      resources :researches, only: [:show, :update, :index, :destroy, :create]
      resources :properties, only: [:show, :index]
      resources :brokers, only: [:show]
      resources :notaries, only: [:show]
      resources :contractors, only: [:show]
      resources :subscriber_notes, only: [:create]
      resources :saved_properties, only: [:create, :destroy]
      
      # Manychat 
      post "/manychat/s/:subscriber_id/update" => "manychat#update_subscriber"
      get "/manychat/s/:subscriber_id/send/props/morning" => "manychat#send_props_morning" 
      get "/manychat/s/:subscriber_id/send/props/favorites" => "manychat#send_props_favorites" 
      get "/manychat/s/:subscriber_id/send/last/:x/props" => "manychat#send_x_last_props"
      post "/manychat/s/:subscriber_id/add_status" => "manychat#create_subscriber_status" 
      get "/manychat/s/:subscriber_id/send/props/:property_id/details" => "manychat#send_prop_details" 
      get "/manychat/s/:subscriber_id/send/props/last/:x/days" => "manychat#send_props_x_days" 
      
      
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
  
  #############
  # 6 - Broker Dashboard
  #############
  
  get "/courtier/dashboard" => "broker_pages#index", :as => :broker_root
  post "/broker/checked" => "broker_pages#checked_by_broker"

end
