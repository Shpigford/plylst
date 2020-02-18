require 'sidekiq_unique_jobs/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  
  devise_for :users, :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks" 
  }
  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  resources :tracks
  resources :playlists
  resources :labs do
    collection do
      get 'most-listened-tracks'
    end
  end

  get 'genres', to: 'pages#genres'
  
  root to: "pages#index"
end
