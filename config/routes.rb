Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  root "static#home"

  namespace "api" do
    namespace "v1" do
      get "/subscribers/fb/:facebook_id" => "subscribers#show_facebook_id"
      resources :subscribers do
        get "/get/props/last/:x/days" => "subscribers#props_x_days"
        # get '/send/props/last/:x/days' => 'subscribers#send_props_x_days'
        # get '/send/props/morning' => 'subscribers#send_props_morning'
        # get '/send/props/:property_id/details' => 'subscribers#send_prop_details'
        # get '/send/props/favorites' => 'subscribers#send_props_favorites'
      end

      resources :properties, only: [:show, :index]

      resources :favorites, only: [:create, :destroy]

      # Manychat routes
      post "/manychat/s/:subscriber_id/update" => "manychat#update_subscriber"
      get "/manychat/s/:subscriber_id/send/props/last/:x/days" => "manychat#send_props_x_days"
      get "/manychat/s/:subscriber_id/send/props/morning" => "manychat#send_props_morning"
      get "/manychat/s/:subscriber_id/send/props/:property_id/details" => "manychat#send_prop_details"
      get "/manychat/s/:subscriber_id/send/props/favorites" => "manychat#send_props_favorites"
      get "/manychat/s/:subscriber_id/send/last/:x/props" => "manychat#send_x_last_props"
    end
  end

  resources :subscribers, only: [:show, :update, :edit]
  resources :properties, only: [:show]
  # put '/subscribers/:id', to "subcribers#update"
  get "/dashboard/" => "static_pages#dashboard"
  get "/dashboard/properties" => "static_pages#properties"
  get "/dashboard/stats" => "static_pages#stats"
  get "/dashboard/chart" => "static_pages#chart"

end
