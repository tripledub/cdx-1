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

        if any_new_or_finished?(test_batch)
          test_batch.update_attribute(:status, 'in_progress')
        elsif all_finished?(test_batch)
          test_batch.update_attribute(:status, 'closed')
        end
      end

      protected

      def any_new_or_finished?(test_batch)
        any_new?(test_batch) && any_finished?(test_batch)
      end

      def all_finished?(test_batch)
        !any_new?(test_batch) && any_finished?(test_batch)
      end

      def any_new?(test_batch)
        test_batch.patient_results.any? { |result| result.result_status == 'new' }
      end

      def any_finished?(test_batch)
        test_batch.patient_results.any? { |result| result.result_status == 'rejected' || result.result_status == 'completed' }
      end
    end
  end
end
