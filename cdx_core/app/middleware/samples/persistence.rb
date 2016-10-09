module Samples
  # Update operations on Samples
  class Persistence
    class << self
      def collect_sample_ids(encounter, sample_ids)
        @error_messages = []
        create_sample_ids(encounter, sample_ids)

        @error_messages.present? ? [@error_messages.join(', '), :unprocessable_entity] : [{ testOrderStatus: 'samples_collected' }, :ok]
      end

      protected

      def create_sample_ids(encounter, sample_ids)
        sample_ids.each do |sample_id|
          add_sample(encounter, sample_id) if sample_is_valid?(sample_id)
        end

        unless @error_messages.present?
          TestOrders::Status.update_and_log(encounter, 'samples_collected')
          encounter.patient_results.each do |patient_result|
            PatientResults::Persistence.update_status_and_log(patient_result, 'sample_collected')
            patient_result.update_attribute(:sample_collected_on, Date.today)
          end
        end
      end

      def sample_is_valid?(sample_id)
        sample_identifiers = SampleIdentifiers::Finder.find_all_by_sample_id(sample_id)
        if sample_identifiers && !sample_assigned?(sample_identifiers)
          @error_messages << I18n.t('samples.collect_samples.sample_exists', sample_id: sample_id)
          return false
        end

        true
      end

      def add_sample(encounter, sample_id)
        new_sample = encounter.samples.new do |sample|
          sample.institution = encounter.institution
          sample.patient = encounter.patient
          sample.sample_identifiers.new do |sample_identifier|
            sample_identifier.lab_sample_id = sample_id
          end
        end

        @error_messages << new_sample.errors.messages unless new_sample.save
      end

      def sample_assigned?(sample_identifiers)
        sample_identifiers.each { |sample_identifier| return false if sample_identifier.patient_results.count.zero? }

        true
      end
    end
  end
end
