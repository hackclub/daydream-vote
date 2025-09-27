Rails.application.routes.draw do
  get "projects/select_role"
  get "projects/wait_for_invite"
  get "projects/invite_members"
  post "projects/invite_members", to: "projects#create_invite"
  get "events/:event/vote", to: "projects#vote", as: :event_vote
  post "events/:event/make_vote_selection", to: "projects#make_vote_selection", as: :event_make_vote_selection
  delete "projects/invites/:invite_id", to: "projects#delete_invite", as: :delete_project_invite
  get "accept_invite/:token", to: "projects#accept_invite", as: :accept_invite
  resource :project, only: [ :edit, :update ] do
    get "review"
    post "submit", to: "projects#submit", as: :submit
  end
  resource :profile, only: [ :edit, :update ]
  get "profile", to: redirect("/profile/edit")
  get "project", to: redirect("/project/edit")
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  resources :sessions, only: [ :create, :destroy ]
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
