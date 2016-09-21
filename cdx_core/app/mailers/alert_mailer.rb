include Alerts

class AlertMailer < ApplicationMailer

  default from: ENV['ALERT_MAILER_SENDER'] || ENV['MAILER_SENDER'] || 'info@instedd.org'

  def alert_email(alert, person, alert_history, message_body, subject_text, alert_count)
    email = person[:email]
    @alert = alert
    @alert_body_text = message_body

    email_with_name = %("#{person[:first_name]}" <#{person[:email]}>)
    mail(to: email,subject: subject_text)

    #record it was send
    record_alert_message(alert, alert_history, person[:user_id], person[:recipient_id], subject_text, Alert.channel_types["email"])
  end

end
