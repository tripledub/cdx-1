module XpertResults
  # Import results from GeneXpert devices
  class Importer
    class << self
      # Tries to link an automated result to an existent one based on sample Id.
      # If no test result exists then it creates an orphan xpert result.
      # sampleId can be reused after some time so we can have many sample_identifiers.
      # We then find the first available xpert result that matches test order.
      def link_xpert_result(parsed_message, device)
        sample_identifiers = SampleIdentifiers::Finder.find_all_samples_available(sample_id_from_parsed_message(parsed_message['sample']))
        xpert_result, @sample_identifier = XpertResults::Finder.available_test(sample_identifiers)
        link_to_current_result(xpert_result, parsed_message, device)
      end

      def valid_gene_xpert_result_and_sample?(device, parsed_message)
        return false unless device.model_is_gen_expert?

        sample_id = sample_id_from_parsed_message(parsed_message['sample'])
        return false unless sample_id

        sample_identifiers = SampleIdentifiers::Finder.find_all_samples_available(sample_id)
        return false unless sample_identifiers

        xpert_result, _sample_identifier = XpertResults::Finder.available_test(sample_identifiers)
        xpert_result.present? && xpert_result.linkable?
      end

      protected

      def link_to_current_result(xpert_result, parsed_message, device)
        if XpertResults::Persistence.update_from_parsed_message(xpert_result, parsed_message)
          xpert_result.sample_identifier = @sample_identifier
          xpert_result.device = device
          xpert_result.save!
          PatientResults::Persistence.update_status_and_log(xpert_result, 'pending_approval')
        end
      end

      def sample_id_from_parsed_message(sample_data)
        sample_data['core']['id']
      end
    end
  end
end
