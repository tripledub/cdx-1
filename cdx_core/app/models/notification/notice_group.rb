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

  serialize :email_messages, Hash
  serialize :sms_messages, Hash

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

  def plain_sms_body
    @plain_sms_body ||=
      String.new.tap do |s|
        sms_messages.each do |message, count|
          s << "#{count} #{Notification.model_name.human}: #{message}"
          s << "\n"
        end
      end
  end

  def complete!
    update_column(:status, 'complete')
  end

  def failed!
    update_column(:status, 'failed')
  end

  private

  def message_counts(messages)
    Hash.new.tap do |h|
      messages.each do |v|
        count = messages.select { |a| a == v }.size
        h[v] = count
      end
    end
  end

  def collate_notification_messages
    self.email_messages =
      message_counts(notification_notices.map { |notice| notice.notification.present? ? notice.notification.email_message : nil }.compact)

    self.sms_messages =
      message_counts(notification_notices.map { |notice| notice.notification.present? ? notice.notification.sms_message : nil }.compact)
  end

  def send_messages
    begin
      email_data.each do |email, count|
        next if email.blank?
        Notifications::Gateway::Email.aggregated(email, count, self)
      end

      telephone_data.each do |telephone, count|
        next if telephone.blank?

        if plain_sms_body.present? && plain_sms_body.length <= 153
          Notifications::Gateway::Sms.aggregated(telephone, count, triggered_at, plain_sms_body)
        else
          Notifications::Gateway::Sms.aggregated(telephone, count, triggered_at)
        end
      end

      complete!
      notification_notices.update_all(status: 'complete')
    rescue => e
      failed!
      notification_notices.update_all(status: 'failed')
    end
  end
end
