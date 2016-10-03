class CheckNotificationJob
  include Sidekiq::Worker

  def perform(klass, record_id, changed_attributes)
    "Notifications::#{klass}Lookup".constantize.prepare_notifications(record_id, changed_attributes)
  end
end
