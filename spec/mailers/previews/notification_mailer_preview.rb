class NotificationPreview < ActionMailer::Preview
  # Accessible from http://localhost:3000/rails/mailers/notifier/welcome
  def aggregated
    @notice_group = Notification::NoticeGroup.first

    NotificationMailer.aggregated('test@example.com', @notice_group, Notifications::Gateway::Email.new(aggregated_count: @notice_group.notification_notices.count, aggregated_at: Time.now))
  end
end
