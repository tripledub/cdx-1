module Devices
  # Presenter method for Devices
  class Presenter
    class << self
      def index_table(devices)
        devices.map do |device|
          {
            id:              device.uuid,
            name:            device.name,
            modelName:       device.device_model.full_name,
            siteName:        Sites::Presenter.site_name(device.site),
            viewLink:        Rails.application.routes.url_helpers.device_path(device.id)
          }
        end
      end

      def device_name(device)
        return '' unless device

        device.name
      end

      def device_name_and_serial_number(device)
        return '' unless device

        "#{device.name} - #{device.serial_number}"
      end
    end
  end
end
