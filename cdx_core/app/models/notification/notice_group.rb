class Notification::NoticeGroup < ActiveRecord::Base
  acts_as_paranoid

  # Relationships
  has_many :notification_notices,
    class_name: 'Notification::Notice',
    foreign_key: :notification_notice_group_id

  STATUSES = %w(
    pending
    complete
    deferred
  ).freeze

  # Validations
  validates :status,          inclusion: { in: STATUSES }
  validates :frequency,       inclusion: { in: Notification::FREQUENCY_TYPES.map(&:last) }
  validates :frequency_value, presence:  { if: -> { frequency == 'aggregate' } },
                              inclusion: { in: Notification::FREQUENCY_VALUES.map(&:last) },
                              allow_nil: true, allow_blank: true
  validates :triggered_at,    presence: true

  serialize :email_data, Hash
  serialize :telephone_data, Hash

  serialize :email_messages, Array
  serialize :sms_messages, Array

  before_create :collate_notification_messages
  after_create  :send_messages

  def last_digest_at
    @last_digest_at ||=
      case frequency_value
        when 'hourly'
          triggered_at - 1.hour
        when 'daily'
          triggered_at - 1.day
        when 'weekly'
          triggered_at - 1.week
        when 'monthly'
          triggered_at - 1.month
        else
          triggered_at
      end
  end

  private

  def collate_notification_messages
    self.email_messages =
      notification_notices.map {|notice| notice.notification.present? ? notice.notification.email_message : nil }.compact.uniq

    self.sms_messages    =
      notification_notices.map {|notice| notice.notification.present? ? notice.notification.sms_message : nil }.compact.uniq
  end

  def send_messages
    email_data.each do |email, count|
      next if email.blank?
      Notifications::Gateway::Email.aggregated(email, count, triggered_at)
    end

    telephone_data.each do |telephone, count|
      next if telephone.blank?
      Notifications::Gateway::Sms.aggregated(telephone, count, triggered_at)
    end

    notification_notices.update_all(status: 'complete')
  end
end
