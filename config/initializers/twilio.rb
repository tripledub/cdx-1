# alternatively, you can preconfigure the client like so

if Settings.twilio
  Twilio.configure do |config|
    config.account_sid = Settings.twilio.sid
    config.auth_token = Settings.twilio.auth_token
  end
end
