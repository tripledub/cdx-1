module Reports
  class DevicesNotReporting < Base
    def generate_chart
      process
      {
        title:   'Devices not reporting',
        titleY:  'Device name',
        columns: generate_columns
      }
    end

    protected

    def process
      devices = Policy.authorize Policy::Actions::READ_DEVICE, Device.within(context.entity), current_user

      devices.each do |device|
        if device.name.length > 0
          if options["date_range"]
            day_range      = ( Date.parse(options["date_range"]["start_time"]["lte"]) -  Date.parse(options["date_range"]["start_time"]["gte"]) ).to_i
            device_message = DeviceMessage.where(:device_id => device.id).where("created_at > ? and created_at < ?",options["date_range"]["start_time"]["lge"],options["date_range"]["start_time"]["lte"]).order(:created_at).first
          else
            day_range      = (Date.parse(Time.now.strftime('%Y-%m-%d')) -  Date.parse(get_since)).to_i
            device_message = DeviceMessage.where(:device_id => device.id).where("created_at > ?", get_since).order(:created_at).first
          end

          if device_message
            days_diff = ( (Time.now - (device_message.created_at) ) / (1.day)).round
            data << { '_label': device.name.truncate(13), '_value': days_diff }
          else
            data << { '_label': device.name, '_value': day_range }
          end
        end
      end
    end

    def generate_columns
      return [] unless data

      [
        {
          type: 'column',
          color: '#9dce65',
          name: 'Device name',
          legendText: 'Device name',
          showInLegend: true,
          dataPoints: data.map { |data_point| { label: data_point['_label'], y: data_point['_value'] } }
        }
      ]
    end

    def get_since
      options["since"] || (Time.now - 12.months).strftime('%Y-%m-%d')
    end
  end
end
