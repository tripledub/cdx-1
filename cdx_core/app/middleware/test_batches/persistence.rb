module TestBatches
  class Persistence
    class << self
      def build_requested_tests(test_batch, tests_requested='|')
        tests_requested.split('|').each do |name|
          new_result = PatientResults::Finder.instance_from_string(name)
          new_result.result_name = name
          test_batch.patient_results << new_result
        end
      end

      def update_status(test_batch)
        test_batch.reload

        if all_finished?(test_batch)
          test_batch.update_attribute(:status, 'closed')
        elsif any_pending_approval_or_finished?(test_batch)
          test_batch.update_attribute(:status, 'in_progress')
        elsif any_sample_received?(test_batch)
          test_batch.update_attribute(:status, 'samples_received')
        end
      end

      protected

      def any_pending_approval_or_finished?(test_batch)
        any_pending_approval?(test_batch) || any_finished?(test_batch)
      end

      def any_finished?(test_batch)
        test_batch.patient_results.any? { |result| result.result_status == 'rejected' || result.result_status == 'completed' }
      end

      def all_finished?(test_batch)
        test_batch.patient_results.all? { |result| result.result_status == 'rejected' || result.result_status == 'completed' }
      end

      def any_pending_approval?(test_batch)
        test_batch.patient_results.any? { |result| result.result_status == 'pending_approval' }
      end

      def any_sample_received?(test_batch)
        test_batch.patient_results.any? { |result| result.result_status == 'sample_received' }
      end
    end
  end
end
