module CdxVietnam
  module Presenters
    class Vtm
      def self.create_patient(patient_result)
        new(patient_result).create_patient
      end

      attr_reader :encounter, :patient, :patient_result

      def initialize(patient_result)
        patient_result.reload
        @patient_result = patient_result
        @encounter = patient_result.encounter
        @patient = @encounter.patient
        @episode = @encounter.patient.episodes.last
      end

      def create_patient
        {
          patient: {
            target_system: 'vtm',
            patient_vtm_id: patient.external_id,
            cdp_id: patient.id.to_s,
            registration_number: 'ANY',
            consulting_professional: 'Dr. Knee',
            diagnosis_date: 'mm/dd/yyyy',
            name: 'Patient One',
            age: '34',
            gender: '1',
            health_insurance_number: 'Any',
            cellphone_number: 'hard-coded',
            registration_address1: '12 Quang Trung',
            registration_province: '',
            registration_district: '',
            current_address: '12 Quang Trung',
            healthcare_unit_province: '',
            healthcare_unit_name: '',
            symptoms: 'any',
            hiv_status: '1',
            test_order: {
              type: 'xpert',
              order_id: 'CDP00001',
              cdp_order_id: patient_result.id.to_s,
              month: 2, 
              next_exam_date: '',
              result: 'NEGATIVE'
            }
          }
        }.to_json
      end
    end
  end
end