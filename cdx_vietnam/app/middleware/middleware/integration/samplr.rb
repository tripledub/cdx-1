$test1 = {
  'test_order' => {
    'type' => 'microscopy',
    'patient_vtm_id' => '1988384',
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

$test2 = {
  'test_order' => {
    'type' => 'xpert',
    'patient_vtm_id' => '1988384',
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


$patient = { 
  'patient' => {
    'registration_number' => '',
    'consulting_professional' => 'Dr. Knee',
    'diagnosis_date' => '10/10/2016',
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
    'hiv_status' => '1'
  }
}

#x = Integration::CdpScraper::VitimesScraper::new('cdp_hoangmai', 'abc123', 'http://42.112.27.165:8888', 'Content-Type' => 'application/json;charset=UTF-8')
#x.create_patient($patient)
#x.create_test_order($expert)