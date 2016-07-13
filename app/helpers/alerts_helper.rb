module AlertsHelper
  include ActionView::Helpers::DateHelper

  def display_devices(alert)
    device_names = []
    alert.devices.each do |device|
      device_names << device.name
    end
    device_names.join(',')
  end
end
