class Cdx::Alert::Conditions::Roles
  attr_reader :roles_ok, :error_text

  def initialize(alert_info, params_roles)
    @alert_info = alert_info
    @roles      = params_roles
    @roles_ok   = true
    @error_text = ''
  end

  def create
    roles = @roles.split(',')
    roles.each do |role_id|
      role                       = Role.find_by_id(role_id)
      alert_recipient            = @alert_info.alert_recipients.new do |recipient|
        recipient.recipient_type = AlertRecipient.recipient_types["role"]
        recipient.role           = role
      end

      if alert_recipient.save == false
        @roles_ok = false
        error_text = error_text.merge alert_recipient.errors.messages
      end
    end
  end
end
