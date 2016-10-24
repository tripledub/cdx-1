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
          'patient' => {
            'registration_number' => '', # OK
            'consulting_professional' => '[FROM CDP]', # OK
            'diagnosis_date' => diagnosis_date,
            'name' => 'Patient Three',
            'age' => '34',
            'gender' => '1',
            'health_insurance_number' => 'Any',
            'healthcare_unit' => '981',
            'cellphone_number' => 'hard-coded',
            'registration_address1' => '12 Quang Trung',
            'registration_province' => '',
            'registration_district' => '',
            'current_address' => '12 Quang Trung',
            'symptoms' => 'any',
            'hiv_status' => '1',
            'test_order' => {
              'type' => 'xpert',
              'hiv_status' => '3',
              'sample_collected_date1' => '2016-10-21T06:56:33.702Z',
              'sample_collected_date2' => '21/10/2016 13:56:33',
              'requesting_site' => 981,
              'performing_site' => 15,
              'specimen_type' => '2',
              'requester' => 'NGHI',
              'result' => '3'
            }
          }
        }.to_json
      end
    end
  end
end