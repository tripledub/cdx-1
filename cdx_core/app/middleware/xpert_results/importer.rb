module XpertResults
  # Import results from GeneXpert devices
  class Importer
    class << self
      # Tries to link an automated result to an existent one based on sample Id
      # If no test result exists then it creates an orphan xpert result
      def link_xpert_result(parsed_message, device)
        sample_identifier = SampleIdentifiers::Finder.find_first_sample_available(sample_id_from_parsed_message(parsed_message['sample']))
        xpert_result = XpertResults::Finder.available_test(sample_identifier.sample.encounter)
        link_to_current_result(xpert_result, sample_identifier, parsed_message, device)
      end

      def valid_gene_xpert_result_and_sample?(device, parsed_message)
        return false unless device.model_is_gen_expert?

        sample_identifier = SampleIdentifiers::Finder.find_first_sample_available(sample_id_from_parsed_message(parsed_message['sample']))
        return false unless sample_identifier

        xpert_result = XpertResults::Finder.available_test(sample_identifier.sample.encounter)
        xpert_result.present? && xpert_result.is_linkable?
      end

      protected

      def link_to_current_result(xpert_result, sample_identifier, parsed_message, device)
        if XpertResults::Persistence.update_from_parsed_message(xpert_result, parsed_message)
          xpert_result.sample_identifier = sample_identifier
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
