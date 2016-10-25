class InstantNotificationJob
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(notice_id)
    notice = Notification::Notice.pending.find(notice_id)

    begin
      notice.create_recipients
      notice.deliver_to_all_recipients
      notice.complete!
    rescue => e
      Rails.logger.info e.message
      Rails.logger.info e.backtrace.join("\n")
      notice.failed!
    end
  end
end
