module TestOrders
  # Logic to handle all different test order status
  class Status
    class << self
      def update_status(encounter)
        if all_finished?(encounter)
          encounter.update_attribute(:status, 'closed')
        elsif any_pending_approval_or_finished?(encounter)
          encounter.update_attribute(:status, 'in_progress')
        elsif any_sample_received?(encounter)
          encounter.update_attribute(:status, 'samples_received')
        elsif order_is_pending?(encounter)
          encounter.update_attribute(:status, 'pending')
        end
      end

      protected

      def order_is_pending?(encounter)
        encounter.payment_done == true && encounter.status == 'samples_collected'
      end

      def any_pending_approval_or_finished?(encounter)
        any_pending_approval?(encounter) || any_finished?(encounter)
      end

      def any_finished?(encounter)
        encounter.patient_results.any? { |result| result.result_status == 'rejected' || result.result_status == 'completed' }
      end

      def all_finished?(encounter)
        encounter.patient_results.all? { |result| result.result_status == 'rejected' || result.result_status == 'completed' }
      end

      def any_pending_approval?(encounter)
        encounter.patient_results.any? { |result| result.result_status == 'pending_approval' }
      end

      def any_sample_received?(encounter)
        encounter.patient_results.any? { |result| result.result_status == 'sample_received' }
      end
    end
  end
end
