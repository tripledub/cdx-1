class Notification::Recipient < ActiveRecord::Base
  acts_as_paranoid

  # Relationships
  belongs_to :notification

  # Validations
  validates :notification, presence: true, on: :update
  validates :email,        presence: { unless: :telephone_present? }, format: { with: Devise.email_regexp, allow_nil: true }
  validates :telephone,    presence: { unless: :email_present? }

  def send_sms
    notification && notification.sms? && telephone_present? && notification.instant? &&
      Notifications::Gateway::Sms.single(telephone, notification.sms_message) &&
      Rails.logger.info("[SMS] Notification::Recipient: ##{telephone} Notification: #{notification.id}")
  end

  def send_email
    notification && notification.email? && email_present? && notification.instant? &&
      Notifications::Gateway::Email.single(email, notification.email_message) &&
      Rails.logger.info("[Email] Notification::Recipient: ##{email} Notification: #{notification.id}")
  end

  def email_present?
    !email.blank?
  end

  def telephone_present?
    !telephone.blank?
  end
end
