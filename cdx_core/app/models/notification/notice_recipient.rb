class Notification::NoticeRecipient < ActiveRecord::Base
  # Relationships
  belongs_to :notification
  belongs_to :notification_notice, class_name: 'Notification::Notice'

  # Validations
  validates :notification, presence: true
  validates :email,        presence: { unless: :telephone_present? }, format: { with: Devise.email_regexp, allow_nil: true }
  validates :telephone,    presence: { unless: :email_present? }

  def send_sms
    notification.sms? && telephone_present? && notification.instant? &&
      Notifications::Gateway::Sms.single(telephone, notification.sms_message) &&
      Rails.logger.info("[SMS] Notification::NoticeRecipient: ##{telephone} Notification: #{notification.id}")
  end

  def send_email
    notification.email? && email_present? && notification.instant? &&
      Notifications::Gateway::Email.single(email, notification.email_message) &&
      Rails.logger.info("[Email] Notification::NoticeRecipient: ##{email} Notification: #{notification.id}")
  end

  def email_present?
    !email.blank?
  end

  def telephone_present?
    !telephone.blank?
  end
end
