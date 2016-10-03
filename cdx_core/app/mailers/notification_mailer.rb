class NotificationMailer < ApplicationMailer
 
  def instant(email_address, body)
    @email_address = email_address
    @body = body

    mail(to: email_address, subject: I18n.t('middleware.notifications.gateway.email.subject'))
  end

  def aggregated(email_address, body)
    @email_address = email_address
    @body    = body

    mail(to: email_address, subject: I18n.t('middleware.notifications.gateway.email.subject'))
  end

end
