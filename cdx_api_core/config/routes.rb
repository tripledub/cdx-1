CdxApiCore::Engine.routes.draw do
  resources :activations, only: :create
  resources :playground, only: :index, defaults: { format: 'html' } do
    collection do
      get :simulator
    end
  end
  match 'tests(.:format)' => "tests#index", via: [:get, :post], defaults: { format: :json }
  resources :tests, only: [], defaults: { format: :json } do
    collection do
      get :schema
    end
    member do
      get :pii
    end
  end
  match 'encounters(.:format)' => "encounters#index", via: [:get, :post], defaults: { format: :json }
  resources :encounters, only: [], defaults: { format: :json } do
    collection do
      get :schema
    end
    member do
      get :pii
    end
  end
  resources :devices, only: [], defaults: { format: :json } do
    resources :messages, only: [:create ], shallow: true, defaults: { format: :json }
    match 'tests' => "messages#create", via: :post # For backwards compatibility with Qiagen-Esequant-LR3
    match 'demodata' => "messages#create_demo", via: :post
  end
  resources :sites, only: :index, defaults: { format: :json }
  resources :institutions, only: :index, defaults: { format: :json }
  resources :filters, only: [:index, :show], defaults: { format: :json } do
    resources :subscribers, defaults: { format: :json }
  end
  resources :subscribers, defaults: { format: :json }
end
