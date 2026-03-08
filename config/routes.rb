Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#show"

  resource :profile, only: [ :show, :update ]
  resource :library, only: [ :show ], controller: "library"
  resource :happy_hour, only: [ :show ], controller: "happy_hour"
  resource :drinking_session, only: [ :create, :destroy ]
  resources :drinking_records, only: [ :create ]
  get "drunk_people", to: redirect("/happy_hour")

  resources :cellars do
    member do
      get :settings
      patch :set_default
    end
    resources :wines, only: [ :index, :show, :create, :edit, :update, :destroy ] do
      member do
        patch :drink
        post :re_add
      end
    end
    resources :invitations, only: [ :index, :create, :destroy ], controller: "cellars/invitations"
    resources :memberships, only: [ :index, :update, :destroy ], controller: "cellars/memberships"
  end

  post "cellars/:cellar_id/wines/scan_label", to: "wines/label_scans#create", as: :scan_cellar_wine_label
  get "cellars/invitations/:token", to: "cellars/invitations#show", as: :cellar_invitation_token
  post "cellars/invitations/:token/accept", to: "cellars/invitations#accept", as: :accept_cellar_invitation
end
