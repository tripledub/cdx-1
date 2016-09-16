module PatientResults
  class Presenter
    class << self
      def for_encounter(patient_results)
        patient_results.map do |patient_result|
          {
            id: patient_result.id,
            turnaround: patient_result.turnaround,
            comment: patient_result.comment,
            name: patient_result.result_name,
            status: patient_result.result_status,
            completed_at: Extras::Dates::Format.datetime_with_time_zone(patient_result.completed_at),
            created_at: Extras::Dates::Format.datetime_with_time_zone(patient_result.created_at),
            updated_at: Extras::Dates::Format.datetime_with_time_zone(patient_result.updated_at)
          }
        end
      end
    end
  end
end
