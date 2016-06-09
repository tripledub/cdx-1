class Cdx::Alert::Conditions::InternalUsers
  attr_reader :internal_users_ok, :error_text

  def initialize(alert_info, params_users_info)
    @alert_info = alert_info
    @users_info = params_users_info
    @internal_users_ok   = true
    @error_text = ''
  end

  def create
    internal_users = @users_info.split(',')
    internal_users.each do |user_id|
      user                       = User.find_by_id(user_id)
      alert_recipient            = @alert_info.alert_recipients.new do |recipient|
        recipient.recipient_type = AlertRecipient.recipient_types["internal_user"]
        recipient.user           = user
      end

      if alert_recipient.save == false
        @internal_users_ok = false
        @error_text        = error_text.merge alert_recipient.errors.messages
      end
    end
  end
end
