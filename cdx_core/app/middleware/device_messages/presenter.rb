module DeviceMessages
  # Presenter methods for DeviceMessages
  class Presenter
    class << self
      def index_view(device_messages)
        device_messages.map do |device_message|
          {
            id:                device_message.id,
            indexStatus:       index_failed(device_message),
            failureReason:     device_message.index_failure_reason,
            modelName:         device_message.device.device_model.name,
            deviceName:        device_message.device.name,
            numberOfFailures:  device_message.index_failure_data[:number_of_failures],
            errorField:        device_message.index_failure_data[:target_field],
            createdAt:         Extras::Dates::Format.datetime_with_time_zone(device_message.created_at, :full_time, device_message.device.time_zone),
            testOrderLink:     message_is_linked(device_message),
            rawLink:           Rails.application.routes.url_helpers.raw_device_message_path(device_message)
          }
        end
      end

      protected

      def index_failed(message)
        if message.index_failed
          {
            failed: "#{I18n.t('device_messages.index.failed')} #{I18n.t('device_messages.index.reprocess')}",
            link:  Rails.application.routes.url_helpers.reprocess_device_message_path(message)
          }
        else
          { success: I18n.t('device_messages.index.success') }
        end
      end

      def message_is_linked(message)
        url = ''
        message.test_results.each do |test_result|
          if test_result.encounter
            url =  Rails.application.routes.url_helpers.encounter_path(test_result.encounter)
            break
          end
        end

        url
      end
    end
  end
end
