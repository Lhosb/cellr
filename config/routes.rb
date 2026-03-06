Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "wines#index"

  resources :cellars do
    resources :wines, only: [ :index, :create ]
    resources :invitations, only: [ :index, :create, :destroy ], controller: "cellars/invitations"
    resources :memberships, only: [ :index, :update, :destroy ], controller: "cellars/memberships"
  end

  post "cellars/:cellar_id/wines/scan_label", to: "wines/label_scans#create", as: :scan_cellar_wine_label
  post "cellars/invitations/:token/accept", to: "cellars/invitations#accept", as: :accept_cellar_invitation
end
