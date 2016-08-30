Rails.application.routes.draw do
  resources :patients do
    resources :episodes
  end
end
