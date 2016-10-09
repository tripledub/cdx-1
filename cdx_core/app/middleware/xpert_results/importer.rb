module XpertResults
  # Import results from GeneXpert devices
  class Importer
    class << self
      # Tries to link an automated result to an existent one based on sample Id
      # If no test result exists then it creates an orphan xpert result
      def link_or_create_xpert_result(device_message)
        device_message.parsed_messages.each do |parsed_message|
          sample_identifier = sample_id_exists?(parsed_message['sample']['core']['id'])
          if sample_identifier.present?
            link_to_current_result(sample_identifier, parsed_message, device_message.device)
          else
            create_orphan_result(parsed_message)
          end
        end
      end

      protected

      def sample_id_exists?(sample_id)
        SampleIdentifiers::Finder.find_first_sample_available(sample_id)
      end

      def link_to_current_result(sample_identifier, parsed_message, device)
        xpert_result = XpertResults::Persistence.update_from_device_message(sample_identifier.encounter, parsed_message)
        xpert_result.sample_identifier = sample_identifier
        xpert_result.device = device
        xpert_result.save!
        #xpert_result.result_status).to eq('pending_approval'
      end

      def create_orphan_result(parsed_message)
      end
    end
  end
end
