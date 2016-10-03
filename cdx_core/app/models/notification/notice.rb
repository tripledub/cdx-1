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
  ).freeze

  # Validations
  validates :alertable, presence: true
  validates :status,    inclusion: { in: STATUSES }

  # Callbacks
  after_create :run_instant_job, if: -> { notification.instant? }

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
    notification_notice_recipients.create(recipients_union.map do |recipient|
      {
        notification: notification,
        first_name:   recipient.first_name,
        last_name:    recipient.last_name,
        email:        recipient.email,
        telephone:    recipient.telephone
      }
    end)

    true
  end

  def deliver_to_all_recipients
    notification_notice_recipients.each do |recipient|
      recipient.send_sms
      recipient.send_email
    end
  end

  def complete!
    notification.update_column(:last_notification_at, Time.now)
    update_column(:status, 'complete')
  end

  private

    def run_instant_job
      InstantNotificationJob.perform_async(id)
    end
end
