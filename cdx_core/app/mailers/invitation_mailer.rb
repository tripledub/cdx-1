class InvitationMailer < ApplicationMailer
  def invite_message(user, role, message, token)
    @user = user
    @role = role
    @token = token
    @message = message

    mail(to: @user.email, subject: I18n.t('invitation_mailer.invite_message.subject'))
  end
end
