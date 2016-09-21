class AlertRecipient < ActiveRecord::Base
  belongs_to :user
  belongs_to :alert
  belongs_to :role

  acts_as_paranoid
  
  enum recipient_type: [:role, :internal_user, :external_user]

  validates_format_of :email,:with => Devise.email_regexp ,allow_nil: true
  validates :telephone, numericality: { only_integer: true } ,allow_nil: true
  #TODO valid phone number: see  https://www.twilio.com/blog/2015/04/validate-phone-numbers-in-ruby-using-the-lookup-api.html

  validate :name_validation
  validate :email_telephone_validation_presence

  private

  def name_validation
    if recipient_type == "external_user"
      if (first_name==nil) || (first_name.length <= 2)
        errors.add(:first_name, I18n.t('models.alert_recipient.firstname_msg'))
      elsif (last_name==nil) || (last_name.length <= 2)
        errors.add(:last_name, I18n.t('models.alert_recipient.lastname_msg'))
      end
    end
  end

  #the email or the phone number must be present
  def email_telephone_validation_presence
    if recipient_type == "external_user"
      if (email==nil || email.length==0) && (telephone==nil || telephone.length==0)
        errors.add(:email, I18n.t('models.alert_recipient.email_phone_msg'))
      end
    end
  end

end
