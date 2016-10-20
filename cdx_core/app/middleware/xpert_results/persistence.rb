module XpertResults
  # create/update actions on xpert results
  class Persistence
    class << self
      def update_from_parsed_message(xpert_result, parsed_message)
        xpert_result.tuberculosis = get_test_result(parsed_message['test']['core']['assays'], 'mtb')
        xpert_result.rifampicin = get_test_result(parsed_message['test']['core']['assays'], 'rif')
        xpert_result.test_id = parsed_message['test']['core']['id']
        xpert_result.examined_by = parsed_message['test']['core']['site_user']
        xpert_result.result_at = Date.today
        xpert_result.save!
      end

      protected

      def get_test_result(assays, test_type)
        assays.each do |assay|
          return convert_result(assay['result']) if assay['condition'] == test_type
        end
      end

      def convert_result(result)
        if result == 'positive'
          'detected'
        elsif result == 'indeterminate'
          'indeterminate'
        else
          'not_detected'
        end
      end
    end
  end
end
