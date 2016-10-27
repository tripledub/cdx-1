require 'spec_helper'

describe Integration::Client do
  let(:patient) {Patient.make}
  let(:encounter) {Encounter.make patient: patient}
  let(:patient_result) {PatientResult.make encounter: encounter}
  let(:json) do
    etb_patient = {
      'patient' => {
        'case_type' => 'suspect',
        'target_system' => 'etb',
        'name' => 'NGHI017X',
        'bdq_id' => '9283479324',
        'cdp_id' => patient.id.to_s,
        'registration_number' => '23423423',
        'national_id_number' => '0343208033',
        'gender' => 'MALE',
        'date_of_birth' => '11/11/1988',
        'age' => '23',
        'mother_name' => 'Khong co',
        'sending_sms' => 'TRUE',
        'treatment_sms' => 'TRUE',
        'phone_number' => '09877656555',
        'cellphone_number' => '9876665543',
        'supervisor2_cellphone' => '0903333333',
        'nationality' => '',
        'registration_address1' => '12 Ha Noi',
        'registration_address2' => '',
        'registration_region' => 'MIỀN BẮC',
        'registration_province' => 'Hà Nội',
        'registration_district' => 'Cầu Giấy',
        'located_at_different_address' => 'FALSE',
        'healthcare_unit_location' => 'Miền Nam',
        'healthcare_unit_name' => 'Quận 1',
        'healthcare_unit_registration_date' => '10/01/2016',
        'suspect_mdr_case_type' => '',
        'diagnosis_date' => '10/01/2016',
        'tb_drug_resistance_type' => 'RIF_RESISTANCE',
        'registration_group' => '',
        'site_of_disease' => '',
        'number_of_previous_tb_treatment' => '',
        'consulting_date' => '10/01/2016',
        'consulting_professional' => 'Dr. Chris',
        'consulting_height' => '170',
        'consulting_weight' => '77',
        'consulting_comment' => '',
        'test_order' => {
          'order_id' => 'CDP00002',
          'cdp_order_id' => patient_result.id.to_s,
          'target_system' => 'etb',
          'type' => 'xpert',
          'sample_collected_date' => '10/06/2016',
          'laboratory_serial_number' => 'XD3432',
          'laboratory_region' => 'MIỀN BẮC',
          'laboratory_name' => 'LABxxx - HẢI PHÒNG',
          'month' =>  '1',
          'date_of_release' => '10/06/2016',
          'result' => '3',
          'comment' =>  'any comment here'
        }
      }
    }
    etb_patient.to_json
  end

  before(:example) do
    client = Integration::Client.new
    x = double('x')
    allow(Integration::CdpScraper::EtbScraper).to receive(:new).and_return(x)
    allow(x).to receive(:login)
    allow(x).to receive(:create_patient).and_return({:success => true, :patient_etb_id => '123456', :error => ""})
    allow(x).to receive(:create_test_order).and_return({:success => true, :error => ""})
    allow(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(patient_result).and_return(json)
    client.integration(json)
  end

  it 'should update external system id after integrating' do
    expect(patient.reload.external_id).to eq('123456')
  end

  it 'should insert log after each integration' do
    expect(IntegrationLog.all.size).to eq(1)
    expect(IntegrationLog.first.status).to eq('Finished')
  end

  it 'should mark patient result as is_synced after integration' do
    expect(patient_result.reload.is_sync).to eq(true)
  end
end
