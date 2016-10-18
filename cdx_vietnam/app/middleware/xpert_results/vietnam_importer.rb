module XpertResults
  # Vietnam uses its own sample id code and sends extra info to store at sample_identifier.
  class VietnamImporter < XpertResults::Importer
    class << self
      def link_xpert_result(parsed_message, device)
        sample_identifier = SampleIdentifiers::Finder.find_first_sample_available(sample_id_from_parsed_message(parsed_message['sample']))
        super(parsed_message, device)
        update_sample_identifier(sample_identifier, parsed_message)
      end

      protected

      def sample_id_from_parsed_message(sample_data)
        notes = sample_data['custom']['xpert_notes']
        any_match = notes.match(/CDPSAMPLE(.*)CDPSAMPLE/)
        any_match ? any_match[1] : nil
      end

      def update_sample_identifier(sample_identifier, parsed_message)
        sample_identifier.lab_id_patient = parsed_message['test']['custom']['xpert_patient_number']
        sample_identifier.lab_id_sample = parsed_message['sample']['core']['id']
        sample_identifier.save!
      end
    end
  end
end
