class Notification::Notice < ActiveRecord::Base
  # Relationships
  belongs_to :notification
  belongs_to :alertable, polymorphic: true
  belongs_to :notification_notice_group,
    class_name: 'Notification::NoticeGroup',
    foreign_key: :notification_notice_group_id

  has_many :notification_notice_recipients,
    class_name: 'Notification::NoticeRecipient',
    foreign_key: :notification_notice_id

  STATUSES = %w(
    pending
    complete
    deferred
    failed
  ).freeze

  # Validations
  validates :alertable, presence: true
  validates :status,    inclusion: { in: STATUSES }

  # Callbacks
  # Let's leave this alone for now.
  # after_commit :run_instant_job, on: :create, if: :instant_notification?

  serialize :data, Hash

  scope :pending, -> { where(status: 'pending') }

  # Job methods
  def users_and_role_users
    @users_and_role_users ||= notification.users | notification.role_users
  end

  def recipients_union
    @recipients_union ||= notification.notification_recipients | users_and_role_users
  end

  def create_recipients
    recipients_union.each do |recipient|
      Rails.logger.info "[Notification::Notice] Create recipient #{recipient.inspect}"

      hash = {
        notification: notification,
        first_name:   recipient.first_name,
        last_name:    recipient.last_name,
        email:        recipient.email,
        telephone:    recipient.telephone
      }

      notification_notice_recipients.create!(hash) unless notification_notice_recipients.where(hash).first
    end

    Rails.logger.info '[Notice] Built recipients'
    true
  end

  def deliver_to_all_recipients
    return if complete?
    notification_notice_recipients.each do |recipient|
      recipient.send_sms && Rails.logger.info("[SMS] Delivered to recipient: ##{recipient.id}")
      recipient.send_email && Rails.logger.info("[Email] Delivered to recipient: # #{recipient.id}")
    end
  end

  def instant_notification?
    notification.instant?
  end

  def pending?
    status == 'pending'
  end

  def complete?
    status == 'complete'
  end

  def complete!
    notification.update_column(:last_notification_at, Time.now)
    update_column(:status, 'complete')
  end

  def failed!
    update_column(:status, 'failed')
  end

  private

  def run_instant_job
    InstantNotificationJob.perform_async(id)
  end
end
