class Cdx::Alert::Conditions::ExternalUsers
  attr_reader :external_users_ok, :error_text

  def initialize(alert_info, params_external_users)
    @alert_info     = alert_info
    @external_users = params_external_users
    @external_users_ok       = true
    @error_text     = ''
  end

  def create
    external_users = @external_users

    # using key/pair as value returned in this format  :
    #  {"0"=>{"id"=>"0", "firstName"=>"a", "lastName"=>"b", "email"=>"c", "telephone"=>"d"}, "1"=>{"id"=>"1", "firstName"=>"aa", "lastName"=>"bb", "email"=>"cc", "telephone"=>"dd"}}
    external_users.each do |key, external_user_value|
      alert_recipient                = @alert_info.alert_recipients.new do |recipient|
        recipient.recipient_type = AlertRecipient.recipient_types["external_user"]
        recipient.email          = external_user_value["email"]
        recipient.telephone      = external_user_value["telephone"]
        recipient.first_name     = external_user_value["first_name"]
        recipient.last_name      = external_user_value["last_name"]
      end
      if alert_recipient.save == false
        @external_users_ok = false
        @error_text = alert_recipient.errors.messages
      end
    end
  end
end
