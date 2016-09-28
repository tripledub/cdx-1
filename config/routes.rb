require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  use_doorkeeper

  mount CdxCore::Engine => "/"

  if Rails.env.development?
    get 'join' => 'home#join'
    get 'design' => 'home#design'
  end
end
