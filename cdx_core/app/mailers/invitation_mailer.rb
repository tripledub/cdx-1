class InvitationMailer < ApplicationMailer
  def invite_message(user, role, message)
    @user = user
    @role = role
    @token = user.raw_invitation_token
    @message = message

    mail(:to => @user.email, :subject => I18n.t("invitation_mailer.subject"))
  end
end
