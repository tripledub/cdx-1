require 'spec_helper'

describe Presenters::DeviceMessages do
  let(:institution)  { Institution.make }
  let(:site)         { Site.make institution: institution }
  let(:device_model) { DeviceModel.make institution: institution }
  let(:device)       { Device.make  institution: institution, site: site, device_model: device_model }

  describe 'patient_view' do
    before :each do
      14.times { DeviceMessage.make device: device }
    end

    it 'should return an array of formated devices' do
      expect(Presenters::DeviceMessages.index_view(DeviceMessage.all).size).to eq(14)
    end

    it 'should return elements formated' do
      expect(Presenters::DeviceMessages.index_view(DeviceMessage.all).first).to eq({
        id:                DeviceMessage.first.id,
        indexStatus:       {:failed=>"Failed (reprocess)", :link=>Rails.application.routes.url_helpers.reprocess_device_message_path(DeviceMessage.first)},
        failureReason:     DeviceMessage.first.index_failure_reason,
        modelName:         DeviceMessage.first.device.device_model.name,
        deviceName:        DeviceMessage.first.device.name,
        numberOfFailures:  DeviceMessage.first.index_failure_data[:number_of_failures],
        errorField:        DeviceMessage.first.index_failure_data[:target_field],
        createdAt:         Extras::Dates::Format.datetime_with_time_zone(DeviceMessage.first.created_at, :long, DeviceMessage.first.device.time_zone),
        rawLink:           Rails.application.routes.url_helpers.raw_device_message_path(DeviceMessage.first)
      })
    end
  end
end
