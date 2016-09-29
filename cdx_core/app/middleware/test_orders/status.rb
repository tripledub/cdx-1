module TestOrders
  # Logic to handle all different test order status
  class Status
    class << self
      def update_status(encounter)
        encounter.reload
        if all_finished?(encounter)
          update_and_log(encounter, 'closed')
        elsif any_pending_approval_or_finished?(encounter)
          update_and_log(encounter, 'in_progress')
        elsif any_sample_received?(encounter)
          update_and_log(encounter, 'samples_received')
        elsif order_is_pending?(encounter)
          update_and_log(encounter, 'pending')
        end
      end

      protected

      def update_and_log(encounter, new_status)
        TestOrders::StatusAuditor.create_status_log(encounter, [encounter.status, new_status])
        encounter.update_attribute(:status, new_status)
      end

      def order_is_pending?(encounter)
        encounter.payment_done == true && encounter.status == 'samples_received'
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
