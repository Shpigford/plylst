require 'sidekiq_unique_jobs/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  get "/sitemap.xml" => "pages#sitemap", :format => "xml", :as => :sitemap
  get "/sitemap-pages.xml" => "pages#sitemap_pages", :format => "xml", :as => :sitemap_pages
  get "/sitemap-playlists.xml" => "pages#sitemap_playlists", :format => "xml", :as => :sitemap_playlists
  
  devise_for :users, :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks" 
  }
  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  resources :tracks

  resources :playlists do
    member do
      get 'duplicate'
    end
  end

  resources :labs do
    collection do
      get 'most-listened-tracks'
      get 'record-labels'
    end
  end

  resources :pages do
    collection do
      get 'home'
      post 'contact'
    end
  end

  get 'genres', to: 'pages#genres'
  
  root to: "pages#index"
end
