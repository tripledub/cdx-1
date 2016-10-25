class CheckNotificationJob
  include Sidekiq::Worker

  def perform(klass, record_id, changed_attributes)
    begin
      "Notifications::#{klass}Lookup".constantize.prepare_notifications(record_id, changed_attributes)
    rescue Notifications::Error::NotImplemented => e
      Rails.logger.info "[Notifications::#{klass}Lookup] not implemented"
    rescue => e
      Rails.logger.info "[Notifications::#{klass}Lookup] failed"
      Rails.logger.info e.inspect
    end
  end
end
