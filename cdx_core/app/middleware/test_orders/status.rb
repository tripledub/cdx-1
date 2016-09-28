module TestOrders
  # Logic to handle all different test order status
  class Status
    class << self
      def update_status(encounter, current_user)
        encounter.reload
        if all_finished?(encounter)
          update_and_log(encounter, current_user, 'closed')
        elsif any_pending_approval_or_finished?(encounter)
          update_and_log(encounter, current_user, 'in_progress')
        elsif any_sample_received?(encounter)
          update_and_log(encounter, current_user, 'samples_received')
        elsif order_is_pending?(encounter)
          update_and_log(encounter, current_user, 'pending')
        end
      end

      protected

      def update_and_log(encounter, current_user, new_status)
        current_user = encounter.user unless current_user

        TestOrders::StatusAuditor.create_status_log(encounter, current_user.id, [encounter.status, new_status])
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
