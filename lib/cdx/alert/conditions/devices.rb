class Cdx::Alert::Conditions::Devices
  def initialize(alert_info, params_devices_info)
    @alert_info   = alert_info
    @devices_info = params_devices_info
  end

  def create
    return unless @devices_info.present?

    devices = @devices_info.split(',')
    query_devices=[]
    devices.each do |deviceid|
      device = Device.find_by_id(deviceid)
      @alert_info.devices << device
      query_devices << device.uuid
    end

    @alert_info.query.merge!({ "device.uuid" => query_devices })
  end
end
