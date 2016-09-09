module Reports
  class DeviceErrorCodes < Base
    attr_reader :statuses

    def self.total_devices
      Device.count
    end

    def process
      filter['test.status'] = 'error'
      filter['group_by'] = 'device.uuid,test.error_code'
      super
    end

    def get_device_location_details
      data = results['tests'].map do |result|
      {
        device: current_device(result["device.uuid"]).name,
        error_code: result["test.error_code"],
        count: result["count"],
        location: current_device(result["device.uuid"]).site.name,
        last_error: latest_error_date(result)
      }
      end
    end

    private

    def current_device(device_uuid)
      ::Device.where(uuid: device_uuid)
    end

    def latest_error_date(result)
      filter = {}
      filter["device.uuid"] =result["device.uuid"]
      filter["error_code"] =result["test.error_code"]
      filter["page_size"] ="1"
      filter["order_by"]="-test.updated_time"
      result = TestResult.query(filter, current_user).execute
      result["tests"][0]["test"]["updated_time"].to_time.strftime("%Y-%m-%d %H:%M:%S")
    end

    def day_results(format, key)
      super
    end

    def results_by_period(format=nil)
      results['tests'].group_by { |t| t['test.start_time'] }
    end
  end
end
