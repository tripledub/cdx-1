CdxApiCore::Engine.routes.draw do
  resources :activations, only: :create
  resources :playground, only: :index, defaults: { format: 'html' } do
    collection do
      get :simulator
    end
  end

  resources :devices, only: [], defaults: { format: :json } do
    resources :messages, only: [:create], shallow: true, defaults: { format: :json }
    match 'tests' => 'messages#create', via: :post # For backwards compatibility with Qiagen-Esequant-LR3
    match 'demodata' => 'messages#create_demo', via: :post
  end

  resources :sites, only: :index, defaults: { format: :json }
  resources :institutions, only: :index, defaults: { format: :json }
end
