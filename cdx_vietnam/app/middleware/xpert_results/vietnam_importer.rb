module XpertResults
  # Vietnam uses its own sample id code and sends extra info to store at sample_identifier.
  class VietnamImporter < XpertResults::Importer
    class << self
      def link_xpert_result(parsed_message, device)
        super(parsed_message, device)
        update_sample_identifier(@sample_identifier, parsed_message)
      end

      protected

      def update_sample_identifier(sample_identifier, parsed_message)
        sample_identifier.lab_id_patient = patient_number_from_parsed_message(parsed_message['test'])
        sample_identifier.lab_id_sample = sample_core_id_from_parsed_message(parsed_message['sample'])
        sample_identifier.save!
      end

      def sample_id_from_parsed_message(sample_data)
        return '' unless sample_data['custom'].present? && sample_data['custom']['xpert_notes'].present?

        notes = sample_data['custom']['xpert_notes']
        any_match = notes.match(/CDPSAMPLE(.*)CDPSAMPLE/)
        any_match ? any_match[1] : nil
      end

      def patient_number_from_parsed_message(test_data)
        return '' unless test_data['custom'].present? && test_data['custom']['xpert_patient_number'].present?

        test_data['custom']['xpert_patient_number']
      end

      def sample_core_id_from_parsed_message(sample_data)
        return '' unless sample_data['core'].present? && sample_data['core']['id'].present?

        sample_data['core']['id']
      end
    end
  end
end
