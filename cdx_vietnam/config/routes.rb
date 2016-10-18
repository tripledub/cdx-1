Rails.application.routes.draw do
  resources :integration_logs , only: [:index, :show] do
    collection do
      get 'retry'
    end
  end
end
