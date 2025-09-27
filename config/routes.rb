Rails.application.routes.draw do
  get "projects/select_role"
  resource :project, only: [:edit, :update]
  resource :profile, only: [:edit, :update]
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  
  resources :sessions, only: [:create, :destroy]
  get "sessions/new", to: "static_pages#landing", as: :new_session
  get "verify_token/:token_id", to: "sessions#verify_token", as: :verify_token
  
  root "static_pages#landing"
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
