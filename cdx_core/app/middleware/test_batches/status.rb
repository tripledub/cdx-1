module TestBatches
  class Status
    class << self
      def change_status(test_batch)
        # Update requested tests probably outdated due to transaction issues.
        test_batch.patient_results.reload

        # if any_tests_in_progress?(encounter)
        #   encounter.update(status: :in_progress)
        # elsif all_tests_pending?(encounter)
        #   encounter.update(status: :pending)
        # elsif all_tests_finished?(encounter)
        #   encounter.update(status: :pending_approval)
        # end
      end

      protected

      def all_tests_finished?(encounter)
        encounter.requested_tests.all? { |rt| rt.status == 'completed' || rt.status == 'rejected' }
      end

      def all_tests_pending?(encounter)
        encounter.requested_tests.all? { |rt| rt.status == 'pending' }
      end

      def any_tests_in_progress?(encounter)
        encounter.requested_tests.any? { |rt| rt.status == 'inprogress' }
      end
    end
  end
end
