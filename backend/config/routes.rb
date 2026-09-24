Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"

      scope :auth, controller: :auth, as: :auth do
        post   "signup", action: :signup
        post   "login",  action: :login
        delete "logout", action: :logout
        get    "me",     action: :me
      end

      resources :cards, only: %i[index show]
    end
  end
end
