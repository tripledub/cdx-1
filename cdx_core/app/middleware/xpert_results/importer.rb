module XpertResults
  # Import results from GeneXpert devices
  class Importer
    class << self
      # Tries to link an automated result to an existent one based on sample Id
      # If no test result exists then it creates an orphan xpert result
      def link_or_create_xpert_result(parsed_message, device)
        sample_identifier = sample_id_exists?(parsed_message['sample']['core']['id'])
        if sample_identifier.present?
          link_to_current_result(sample_identifier, parsed_message, device)
        else
          create_orphan_result(parsed_message)
        end
      end

      protected

      def sample_id_exists?(sample_id)
        SampleIdentifiers::Finder.find_first_sample_available(sample_id)
      end

      def link_to_current_result(sample_identifier, parsed_message, device)
        xpert_result = XpertResults::Persistence.update_from_parsed_message(sample_identifier.sample.encounter, parsed_message)
        xpert_result.sample_identifier = sample_identifier
        xpert_result.device = device
        xpert_result.result_on = Date.today
        xpert_result.save!
        PatientResults::Persistence.update_status_and_log(xpert_result, 'pending_approval')
      end

      def create_orphan_result(parsed_message)
      end
    end
  end
end
