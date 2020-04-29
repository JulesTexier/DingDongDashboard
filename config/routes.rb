Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :admins
  get 'lead/create'
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  root "static#home"

  namespace "api" do
    namespace "v1" do
      get "/subscribers/fb/:facebook_id" => "subscribers#show_facebook_id"
      resources :subscribers do
        get "/get/props/last/:x/days" => "subscribers#props_x_days"
      end

      resources :properties, only: [:show, :index]
      resources :leads, only: [:index, :show, :update]
      resources :brokers, only: [:show]
      resources :favorites, only: [:create, :destroy]

      # Manychat routes
        # Subscriber
      post "/manychat/s/:subscriber_id/update" => "manychat#update_subscriber"
      post "/manychat/s/create-from-lead" => "manychat#create_subscriber_from_lead"
      get "/manychat/s/:subscriber_id/send/props/last/:x/days" => "manychat#send_props_x_days"
      get "/manychat/s/:subscriber_id/send/props/morning" => "manychat#send_props_morning"
      get "/manychat/s/:subscriber_id/send/props/:property_id/details" => "manychat#send_prop_details"
      get "/manychat/s/:subscriber_id/send/props/favorites" => "manychat#send_props_favorites"
      get "/manychat/s/:subscriber_id/send/last/:x/props" => "manychat#send_x_last_props"
      post "/manychat/s/:subscriber_id/onboard_broker" => "manychat#onboard_old_users"
      # Lead
      post "/manychat/l/:lead_id/update" => "manychat#update_lead"

      # Typeform resources 
      post "/typeform/lead/new" => "typeform#generate_lead"

      # Trello resources 
      post "/trello/send-email-chatbot" => "trello#send_chatbot_link_from_trello_btn"
      post "/trello/add_action" => "trello#add_action_to_broker"
      post "/trello/move-card-to-broker" => "trello#update_lead_broker"

      # Webhooks resources 
      post "webhooks/postmark/inbound" => "webhooks#handle_postmark_inbound"

      #data
      get "data/subscribers" => "data#get_subscribers"
      get "data/subscribers/active" => "data#get_active_subscribers"

    end
  end

  resources :subscribers, only: [:show, :update, :edit]
  resources :properties, only: [:show]
  resources :lead, only: [:new, :create]

  get "/lead/inscription-1" => "lead#inscription_1"
  get "/lead/inscription-2" => "lead#inscription_2"
  get "/lead/inscription-finalisee" => "lead#inscription_4"
  
  get "/dashboard/" => "static_pages#dashboard"
  get "/dashboard/properties" => "static_pages#properties"
  get "/dashboard/stats" => "static_pages#stats"
  get "/dashboard/chart" => "static_pages#chart"
  get "/dashboard/price" => "static_pages#property_price"
  get "/dashboard/source" => "static_pages#sources"

end
