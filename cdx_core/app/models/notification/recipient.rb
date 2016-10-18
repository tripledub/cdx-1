class Notification::Recipient < ActiveRecord::Base
  acts_as_paranoid

  # Relationships
  belongs_to :notification

  # Validations
  validates :notification, presence: true, on: :update
  validates :email,        presence: { if: :missing_telephone? }, format: { with: Devise.email_regexp }
  validates :telephone,    presence: { if: :missing_email? }

  def send_sms
    notification.sms? && !telephone.blank? && notification.instant? &&
      Notifications::Gateway::Sms.single(telephone, notification.sms_message)
  end

  def send_email
    notification.email? && !email.blank? && notification.instant? &&
      Notifications::Gateway::Email.single(self, notification.email_message)
  end

  def missing_email?
    email.blank?
  end

  def missing_telephone?
    telephone.blank?
  end
end
