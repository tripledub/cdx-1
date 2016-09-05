require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  use_doorkeeper

  mount CdxApiCore::Engine => "/api"

  #mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env == 'development'

  if Rails.env.development?
    get 'join' => 'home#join'
    get 'design' => 'home#design'
  end
end
