module Notifications
  module Gateway
    class Email
      attr_accessor :email_address, :body, :response

      def self.aggregated(email_address, aggregated_count, aggregated_at, body = nil)
        gateway = new(email_address: email_address, aggregated_count: aggregated_count, aggregated_at: aggregated_at)
        gateway.body = String.new.tap do |s|
          if body
            s << body
            s << "\n\n"
          end
          s << I18n.t('middleware.notifications.gateway.email.aggregated_body', count: aggregated_count, date: I18n.l(aggregated_at, format: :long))
        end
        gateway.send_aggregated
      end

      def self.single(email_address, body)
        gateway = new(email_address: email_address, body: body)
        gateway.send_single
      end

      def initialize(options = {})
        @email_address = options[:email_address]
        @body = options[:body]
        @aggregated_count = options[:aggregated_count]
        @aggregated_at = options[:aggregated_at]
      end

      def credentials?
        !(email_address.blank? && body.blank?)
      end

      def send_single
        return false unless credentials?
        NotificationMailer.instant(email_address, body).deliver_now
        true
      end

      def send_aggregated
        return false unless credentials?
        NotificationMailer.aggregated(email_address, body).deliver_now
        true
      end
    end
  end
end
