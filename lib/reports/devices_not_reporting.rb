module Reports
  class DevicesNotReporting < Base
    def generate_chart
      process
      {
        title:   '',
        titleY:  'Days',
        columns: generate_columns
      }
    end

    protected

    def process
      devices = Policy.authorize Policy::Actions::READ_DEVICE, ::Device.within(context.entity), current_user

      devices.each do |device|
        if device.name.length > 0
          if options["date_range"]
            day_range      = ( Date.parse(options["date_range"]["start_time"]["lte"]) -  Date.parse(options["date_range"]["start_time"]["gte"]) ).to_i
            device_message = DeviceMessage.where(:device_id => device.id).where("created_at > ? and created_at < ?",options["date_range"]["start_time"]["lge"],options["date_range"]["start_time"]["lte"]).order(:created_at).first
          else
            day_range = (Date.parse(Time.now.strftime('%Y-%m-%d')) -  Date.parse(filter['since'])).to_i
            device_message = DeviceMessage.where(:device_id => device.id).where("created_at > ?", get_since).order(:created_at).first
          end

          if device_message
            days_diff = ( (Time.now - (device_message.created_at) ) / (1.day)).round
            data << { label: device.name.truncate(13), value: days_diff }
          else
            device_since_created = ( (Time.now - (device.created_at) ) / (1.day)).round
            if device_since_created < day_range
              device_days = device_since_created
            else
              device_days = day_range
            end
           data << { label: device.name, value: device_days}
          end
        end
      end
    end

    def get_since
      options["since"] || (Time.now - 12.months).strftime('%Y-%m-%d')
    end

    def generate_columns
      [
        {
          bevelEnabled: false,
          type: "column",
          color: "#E06023",
          name: "Days",
          legendText: "Device",
          showInLegend: true,
          dataPoints: data.map { |result| { label: result[:label], y: result[:value] } }
        }
      ]
    end
  end
end
