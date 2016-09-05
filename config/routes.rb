require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  use_doorkeeper

  #mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env == 'development'
  mount CdxApiCore::Engine => "/api"

  if Rails.env.development?
    get 'join' => 'home#join'
    get 'design' => 'home#design'
  end
end
