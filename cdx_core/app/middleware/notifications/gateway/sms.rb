module Notifications
  module Gateway
    class Sms
      attr_accessor :phone_number, :body, :response

      def self.aggregated(phone_number, aggregated_count, aggregated_at, body = nil)
        gateway = new(phone_number: phone_number)
        gateway.body = (body || I18n.t('middleware.notifications.gateway.sms.aggregated_body', count: aggregated_count, date: I18n.l(aggregated_at, format: :long)))
        gateway.send_message
      end

      def self.single(phone_number, body)
        gateway = new(phone_number: phone_number, body: body)
        gateway.send_message
      end

      def self.verify_number(phone_number)
        new(phone_number: phone_number)
          .valid?
      end

      def initialize(options = {})
        @phone_number = options[:phone_number]
        @body = options[:body]
      end

      def credentials?
        !phone_number.blank? && !body.blank?
      end

      def sanitize_phone_number!
        phone_number.remove!(/\D/)
      end

      def send_message
        return unless credentials?
        #sanitize_phone_number!
        if Settings.twilio_enabled
          @response = twilio_client.messages.create(
            from: Settings.twilio_phone_number,
            to: phone_number,
            body: body
          )
          Rails.logger.info @response.inspect
        else
          Rails.logger.info "[SMS] Twilio not setup or disabled"
          Rails.logger.info "[SMS] To: #{phone_number}"
        end

        true
      end

      def valid?
        return true unless Settings.twilio_enabled

        begin
          phone_number = twilio_number.phone_number
          true
        rescue Twilio::REST::RequestError => e
          false
        end
      end

      def twilio_number
        @twilio_number ||= twilio_lookup_client.phone_numbers.get(phone_number)
      end

      def twilio_lookup_client
        @twilio_lookup_client ||= Twilio::REST::LookupsClient.new
      end

      def twilio_client
        @twilio_client ||= Twilio::REST::Client.new
      end
    end
  end
end
