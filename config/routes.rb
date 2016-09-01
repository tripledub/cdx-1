require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  use_doorkeeper

  #mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env == 'development'

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
end
