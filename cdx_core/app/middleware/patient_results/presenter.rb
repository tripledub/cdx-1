module PatientResults
  class Presenter
    class << self
      def for_encounter(patient_results)
        patient_results.map do |patient_result|
          {
            id: patient_result.id,
            testType:
            orderedBy:
            comment: patient_result.comment,
            status: patient_result.result_status,
            completedAt: Extras::Dates::Format.datetime_with_time_zone(patient_result.completed_at),
            createdAt:   Extras::Dates::Format.datetime_with_time_zone(patient_result.created_at),
            updatedAt:   Extras::Dates::Format.datetime_with_time_zone(patient_result.updated_at)
          }
        end
      end
    end
  end
end
