# alternatively, you can preconfigure the client like so

if Settings.twilio_enabled
  Twilio.configure do |config|
    config.account_sid = Settings.twilio_sid
    config.auth_token = Settings.twilio_auth_token
  end
end
