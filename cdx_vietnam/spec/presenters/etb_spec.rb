require 'spec_helper'

RSpec.describe CdxVietnam::Presenters::Etb do
  let(:user) { User.make }
  let!(:institution) { user.institutions.make }
  let(:address) { Address.make }
  let(:patient) do
    Patient.make(
      institution: institution,
      addresses: [address],
      social_security_code: '1234567890',
      birth_date_on: '12/12/1965',
      core_fields: {
        gender: 'male'
      }
    )
  end
  let(:encounter) { Encounter.make patient: patient }
  
  let(:patient_result) { PatientResult.make encounter: encounter }

  let(:expected_microcopy) do
    etb_patient = {
      patient: {
        case_type: 'patient',
        cdp_id: '',
        target_system: 'etb',
        patient_etb_id: '1294091',
        bdq_id: '000000',
        name: patient.name,
        registration_number: '',
        gender: 'MALE',
        date_of_birth: '12/12/1965',
        age: 50,
        national_id_number: '023232323',
        mother_name: '',
        sending_sms: 'FALSE',
        treatment_sms: 'FALSE',
        phone_number: '23711', 
        cellphone_number: '23711',
        supervisor2_cellphone: '23711',
        nationallity: 'NATIVE',
        registration_address1: '12 Ha Noi',
        registration_address2: '',
        registration_region: 'MIỀN BẮC',
        registration_province: 'Hà Nội',
        registraiton_district: 'Cầu Giấy',
        located_at_different_address: 'FALSE',
        current_address: '12 Ha Noi',
        healthcare_unit_location: 'Miền Nam',
        healthcare_unit_name: 'Quận 1',
        healthcare_unit_registration_date: '10/01/2016',
        suspect_mdr_case_type: '',
        diagnosis_date: encounter.updated_at.strftime('%m/%d/%Y'),
        tb_drug_resistance_type: 'RIF_RESISTANCE',
        registration_group: '',
        site_of_disease: '',
        number_of_previous_tb_treatment: '',
        consulting_date: encounter.created_at.strftime('%m/%d/%Y'),
        consulting_professional: 'Dr Feelgood',
        consulting_height: '181',
        consulting_weight: '79',
        consulting_comment: '',
        test_orders: [
          {
            type: 'microscopy',
            order_id: '34',
            cdp_order_id: '22',
            sample_collected_date: '10/06/2016',
            month: 2,
            specimen_type: 'SPUTUM',
            laboratory_serial_number: 'N3432',
            visual_appearance: 'random',
            laboratory_region: 'MIỀN BẮC',
            laboratory_name: 'LAB - HƯNG YÊN',
            next_exam_date: '',
            date_of_release: '10/06/2016',
            result: 'NEGATIVE',
            comment: 'any comment here'
          }
        ]
      }
    }
    etb_patient.to_json
  end

  let(:expected_xpert) do
    etb_patient = {
      patient: {
        case_type: 'patient',
        cdp_id: '',
        target_system: 'etb',
        patient_etb_id: '1294091',
        bdq_id: '000000',
        name: patient.name,
        registration_number: '',
        gender: 'MALE',
        date_of_birth: '12/12/1965',
        age: 50,
        national_id_number: '023232323',
        mother_name: '',
        sending_sms: 'FALSE',
        treatment_sms: 'FALSE',
        phone_number: '23711', 
        cellphone_number: '23711',
        supervisor2_cellphone: '23711',
        nationallity: 'NATIVE',
        registration_address1: '12 Ha Noi',
        registration_address2: '',
        registration_region: 'MIỀN BẮC',
        registration_province: 'Hà Nội',
        registraiton_district: 'Cầu Giấy',
        located_at_different_address: 'FALSE',
        current_address: '12 Ha Noi',
        healthcare_unit_location: 'Miền Nam',
        healthcare_unit_name: 'Quận 1',
        healthcare_unit_registration_date: '10/01/2016',
        suspect_mdr_case_type: '',
        diagnosis_date: encounter.updated_at.strftime('%m/%d/%Y'),
        tb_drug_resistance_type: 'RIF_RESISTANCE',
        registration_group: '',
        site_of_disease: '',
        number_of_previous_tb_treatment: '',
        consulting_date: encounter.created_at.strftime('%m/%d/%Y'),
        consulting_professional: 'Dr Feelgood',
        consulting_height: '181',
        consulting_weight: '79',
        consulting_comment: '',
        test_orders: [
          {
            type: 'xpert',
            order_id: '34',
            cdp_order_id: '22',
            sample_collected_date: '10/06/2016',
            month: 2,
            laboratory_serial_number: 'N3432',
            laboratory_region: 'MIỀN BẮC',
            laboratory_name: 'LAB - HƯNG YÊN',
            next_exam_date: '',
            date_of_release: '10/06/2016',
            result: 2,
            comment: 'any comment here'
          }
        ]
      }
    }
    etb_patient.to_json
  end

  before do
    # Set time so that age calculation doesn't
    # break in the future
    t = Time.local(2016, 10, 10, 10, 5, 0)
    Timecop.travel(t)
  end

  describe 'create_patient' do
    it 'returns a JSON representation of patient and microscopy test result of patient for ETB API' do
      expect(described_class.create_patient(encounter)).to eq(expected)
    end

  end
end
