module PatientResults
  # Patient results presenter
  class Presenter
    class << self
      include Rails.application.routes.url_helpers
      include ActionDispatch::Routing::PolymorphicRoutes

      def for_encounter(patient_results)
        patient_results.map do |patient_result|
          {
            id:              patient_result.id,
            testType:        patient_result.test_name.to_s,
            sampleId:        sample_id(patient_result),
            examinedBy:      patient_result.examined_by.to_s,
            comment:         patient_result.comment.to_s,
            status:          patient_result.result_status,
            completedAt:     Extras::Dates::Format.datetime_with_time_zone(patient_result.completed_at),
            createdAt:       Extras::Dates::Format.datetime_with_time_zone(patient_result.created_at),
            feedbackMessage: FeedbackMessages::Finder.find_text_from_patient_result(patient_result),
            editUrl:         edit_polymorphic_path([patient_result.encounter, patient_result]),
            showResultUrl:   show_result_url(patient_result)
          }
        end
      end

      protected

      def show_result_url(patient_result)
        patient_result.valid? ? polymorphic_path([patient_result.encounter, patient_result]) : ''
      end

      def sample_id(patient_result)
        patient_result.sample_identifier.present? ? patient_result.sample_identifier.lab_sample_id.to_s : ''
      end
    end
  end
end
