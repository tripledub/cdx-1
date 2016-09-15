module TestBatches
  class Persistence
    class << self
      def build_requested_tests(test_batch, tests_requested='|')
        tests_requested.split('|').each do |name|
          new_result = PatientResults::Finder.instance_from_string(name)
          new_result.result_name = name
          new_result.result_status ='new'
          test_batch.patient_results << new_result
        end
      end
    end
  end
end
