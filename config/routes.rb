Rails.application.routes.draw do
  get "characters/index"
  get "characters/show"
  get "issues/index"
  get "issues/show"
  get "volumes/index"
  get "volumes/show"
  get "publishers/index"
  get "publishers/show"

  get "up" => "rails/health#show", as: :rails_health_check

  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "pages#home"
  get "about", to: "pages#about"
  resources :publishers, only: [ :index, :show ]
  resources :volumes, only: [ :index, :show ]
  resources :issues, only: [ :index, :show ]
  resources :characters, only: [ :index, :show ]
end
