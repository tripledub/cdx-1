class Notification::NoticeRecipient < ActiveRecord::Base
  # Relationships
  belongs_to :notification
  belongs_to :notification_notice, class_name: 'Notification::Notice'

  # Validations
  validates :notification, presence: true
  validates :email,        presence: { if: :missing_telephone? }, format: { with: Devise.email_regexp }
  validates :telephone,    presence: { if: :missing_email? }

  def send_sms
    return if missing_telephone?
    Notifications::Gateway::Sms.single(telephone, notification.sms_message)
  end

  def send_email
    return if missing_email?
    Notifications::Gateway::Email.single(email, notification.email_message)
  end

  private

  def missing_email?
    email.blank?
  end

  def missing_telephone?
    telephone.blank?
  end
end
