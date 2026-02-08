Rails.application.routes.draw do
  # Quick upload
  get "u/view", to: "uploads#index", as: :view_uploads
  get "u", to: "uploads#new", as: :uploads
  post "u", to: "uploads#create"

  resource :session
  resources :passwords, param: :token
  resources :api_tokens, only: [ :index, :new, :create, :destroy ]

  get "dashboard", to: "dashboard#index"
  get "about", to: "about#index"
  get "colophon", to: "colophon#index"
  get "bookmarklet", to: "bookmarklet#index"

  # Bookmarks
  resources :bookmarks

  # Galleries, Albums, and Photos
  resources :galleries do
    resources :albums, only: [ :new, :create ], shallow: true
  end

  resources :albums, except: [ :new, :create ] do
    resources :photos, only: [ :new, :create ], shallow: true
    resources :videos, only: [ :new, :create ], shallow: true
  end

  resources :photos, except: [ :new, :create ]
  resources :videos

  # Short URL redirects
  get "x/:short_code", to: "short_urls#show", as: :short_url
  get "c/:short_code", to: "short_urls#show_media", as: :media_short_url
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
