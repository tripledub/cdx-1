module Notifications
  module Gateway
    class Email
      attr_accessor :email_address, :body, :response
      attr_reader :aggregated_count, :aggregated_at

      def self.aggregated(email_address, aggregated_count, notice_group, aggregated_at = Time.now)
        gateway = new(email_address: email_address, aggregated_count: aggregated_count, aggregated_at: aggregated_at)
        gateway.send_aggregated(notice_group)
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

      def send_aggregated(notice_group)
        return false if email_address.blank?
        NotificationMailer.aggregated(email_address, notice_group, self).deliver_now
        true
      end
    end
  end
end
