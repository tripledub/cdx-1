class InstantNotificationJob
  include Sidekiq::Worker

  def perform(notice_id)
    notice = Notification::Notice.find(notice_id)
    notice.create_recipients
    notice.deliver_to_all_recipients
    notice.complete!
  end
end
