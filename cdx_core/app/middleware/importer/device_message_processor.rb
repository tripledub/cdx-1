module Importer
  # Given a parse messages from device_message
  class DeviceMessageProcessor
    attr_reader :device_message

    def initialize(device_message)
      @device_message = device_message
    end

    def process
      @device_message.parsed_messages.map do |parsed_message|
        Importer::SingleMessageProcessor.new(self, parsed_message).process
      end
    end

    def client
      @client ||= Cdx::Api.client
    end

    def device
      @device_message.device
    end

    def institution
      @device_message.institution
    end
  end
end
