Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  # Global Admin Interface
  namespace :admin do
    resources :workshops
    resources :users
    root to: "workshops#index"
  end

  # Public Home (Optional, can just be a landing page)
  root "pages#home"

  # Workshop Tenancy Scope
  # /my-workshop/vehicles
  scope ':workshop_slug', as: :workshop do
    resources :vehicles do
      member do
        # Specific actions for uploading via AJAX or separate endpoints if needed
        # Standard update can handle it too, but separate endpoints often cleaner for drag-drop
        delete :delete_attachment
        delete :destroy_attachments
      end
      # collection do
      #   get :search
      # end

      # Download all as ZIP
      get :download_all, on: :member
    end

    # Workshop Dashboard
    get '/', to: 'vehicles#index', as: :dashboard
  end
end
