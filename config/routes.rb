Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    # Auth
    post "auth/register", to: "auth#register"
    post "auth/confirm_registration", to: "auth#confirm_registration"
    post "auth/login", to: "auth#login"
    post "auth/confirm_login", to: "auth#confirm_login"
    post "auth/refresh", to: "auth#refresh"
    delete "auth/logout", to: "auth#logout"

    # User Profile
    resource :profile, only: [:show, :update], controller: "profile" do
      post :upload_photo
      post :upload_id_card
      get :approvals
      get :active_approvals
    end

    # Venues (for users)
    resources :venues, only: [:index, :show] do
      member do
        get :events
      end
    end

    # Approvals (for users)
    resources :approvals, only: [:index, :show, :create] do
      member do
        get :qr_code
      end
    end

    # Admin namespace (protected — requires venue_admin role)
    namespace :admin do
      # Venue Management
      resources :venues do
        # Event Management
        resources :events do
          collection do
            get :upcoming
          end
        end

        # Approval Management
        resources :approvals, only: [:index, :show] do
          collection do
            get :pending
          end
          member do
            post :approve
            post :reject
          end
        end

        # QR Scanner
        post :scan, to: "qr_scanner#scan"
        post :validate, to: "qr_scanner#validate"
      end
    end
  end
end
