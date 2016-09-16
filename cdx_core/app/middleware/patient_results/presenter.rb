module PatientResults
  class Presenter
    class << self
      def for_encounter(patient_results)
        patient_results.map do |patient_result|
          {
            id: patient_result.id,
            turnaround: patient_result.turnaround,
            comment: patient_result.comment,
            name: requested_test.result_name,
            status: requested_test.result_status,
            completed_at: Extras::Dates::Format.datetime_with_time_zone(requested_test.completed_at),
            created_at: Extras::Dates::Format.datetime_with_time_zone(requested_test.created_at),
            updated_at: Extras::Dates::Format.datetime_with_time_zone(requested_test.updated_at)
          }
        end
      end
    end
  end
end
