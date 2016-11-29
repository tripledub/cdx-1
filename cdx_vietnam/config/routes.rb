Rails.application.routes.draw do
  resources :integration_logs , only: [:index, :show] do
    collection do
      get 'retry'
    end
  end

  resources :test_orders_state, only: [:index, :show] do
    collection do
      get :patients
    end
  end
end
