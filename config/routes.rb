Rails.application.routes.draw do

  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace 'api' do 
    namespace 'v1' do 
      resources :subscribers do 
        get '/firstname' => 'subscribers#firstname'
        get '/get/props/last/:x/days' => 'subscribers#props_x_days'
        get '/send/props/last/:x/days' => 'subscribers#send_props_x_days'
        get '/send/props/morning' => 'subscribers#send_props_morning'
        get '/send/props/:property_id/details' => 'subscribers#send_prop_details'
        get '/send/props/favorites' => 'subscribers#send_props_favorites'
      end

      resources :properties, only: [:show, :index]

      resources :favorites, only: [:create, :destroy]

      # Manychat routes
      get '/manychat/s/:subscriber_id/send/props/last/:x/days' => 'manychat#send_props_x_days'
      get '/manychat/s/:subscriber_id/send/props/morning' => 'manychat#send_props_morning'
      get '/manychat/s/:subscriber_id/send/props/:property_id/details' => 'manychat#send_prop_details'
      get '/manychat/s/:subscriber_id/send/props/favorites' => 'manychat#send_props_favorites'

    end
  end

  resources :subscribers, only: [:show, :update, :edit]
  resources :properties, only: [:show]
  # put '/subscribers/:id', to "subcribers#update"

end
