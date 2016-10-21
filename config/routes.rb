require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  use_doorkeeper

  #mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env == 'development'
  mount CdxApiCore::Engine => "/api"

  if Settings.sidekiq_web
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      # Protect against timing attacks: (https://codahale.com/a-lesson-in-timing-attacks/)
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use `secure_compare` to stop length information leaking
      ActiveSupport::SecurityUtils.secure_compare(username, Settings.sidekiq_web_username) &
        ActiveSupport::SecurityUtils.secure_compare(password, Settings.sidekiq_web_password)
    end if Rails.env.production?
    mount Sidekiq::Web, at: "/sidekiq"
  end

  if Rails.env.development?
    get 'join' => 'home#join'
    get 'design' => 'home#design'
  end
end
