module XpertResults
  # create/update actions on xpert results
  class Persistence
    class << self
      def update_from_parsed_message(encounter, parsed_message)
        xpert_result = XpertResults::Finder.available_test(encounter)
        return unless xpert_result

        xpert_result.tuberculosis = get_test_result(parsed_message['test']['core']['assays'], 'mtb')
        xpert_result.rifampicin = get_test_result(parsed_message['test']['core']['assays'], 'rif')
        xpert_result.test_id = parsed_message['test']['core']['id']
        xpert_result.save!
        xpert_result
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
