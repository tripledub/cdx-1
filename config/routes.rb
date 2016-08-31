require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  use_doorkeeper

  #mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env == 'development'

  if Settings.single_tenant
    devise_for(
      :users,
      controllers: {
        sessions: 'sessions',
        invitations: 'users/invitations'
      }
    )
    as :user do
      get 'users/registration/edit', to: 'registrations#edit', as: :edit_user_registration, defaults: { format: 'html' }
      match 'users/registration/update(.:model)',
            to: 'registrations#update',
            as: :registration,
            via: [:post, :put]
    end
  else
    devise_for(
      :users,
      controllers: {
        omniauth_callbacks: 'omniauth_callbacks',
        sessions: 'sessions',
        registrations: 'registrations',
        invitations: 'users/invitations'
      },
      path_names: {
        registration: 'registration'
      }
    )
  end

  devise_scope :user do
    root to: "devise/sessions#new"
  end

  get 'verify' => 'home#verify'

  if Rails.env.development?
    get 'join' => 'home#join'
    get 'design' => 'home#design'
  end

  namespace :api, defaults: { format: 'json' } do
    resources :activations, only: :create
    resources :playground, only: :index, defaults: { format: 'html' } do
      collection do
        get :simulator
      end
    end
    match 'tests(.:format)' => "tests#index", via: [:get, :post]
    resources :tests, only: [] do
      collection do
        get :schema
      end
      member do
        get :pii
      end
    end
    match 'encounters(.:format)' => "encounters#index", via: [:get, :post]
    resources :encounters, only: [] do
      collection do
        get :schema
      end
      member do
        get :pii
      end
    end
    resources :devices, only: [] do
      resources :messages, only: [:create ], shallow: true
      match 'tests' => "messages#create", via: :post # For backwards compatibility with Qiagen-Esequant-LR3
      match 'demodata' => "messages#create_demo", via: :post
    end
    resources :sites, only: :index
    resources :institutions, only: :index
    resources :filters, only: [:index, :show] do
      resources :subscribers
    end
    resources :subscribers
  end

  get 'nndd' => 'application#nndd' if Rails.env.test?
end
