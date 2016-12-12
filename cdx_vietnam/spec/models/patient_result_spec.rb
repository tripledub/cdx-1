require 'spec_helper'

RSpec.describe PatientResult do
  let(:current_user)          { User.make }
  let(:institution)           { Institution.make(user_id: current_user.id) }
  let(:site)                  { Site.make(institution: institution) }
  let(:patient)               { Patient.make institution: institution, gender: 'male' }
  let(:pre_encounter)             { Encounter.make institution: institution, user: current_user, patient: patient }
  let(:encounter)             { Encounter.make institution: institution, user: current_user, patient: patient }
  let(:microscopy_result)     { MicroscopyResult.make created_at: 3.days.ago, encounter: encounter, result_name: 'microscopy'}
  let(:xpert_result)          { XpertResult.make encounter: encounter, tuberculosis: 'indeterminate', result_at: 3.days.ago, result_name: 'xpertmtb' }
  # let(:json)                  { CdxVietnam::Presenters::Etb.create_patient(xpert_result) }
  let(:json) do 
    {
      patient: {
            case_type: 'patient', # OK, luôn là patient
            cdp_id: "123",
            target_system: 'etb', # OK
            patient_etb_id: "234",
            bdq_id: '000000', # OK, hard-coded
            name: patient.name,  
            registration_number: '', # not required
            gender: 'male', # that ok but eTB:gender not have 'other' value
            date_of_birth: Extras::Dates::Format.datetime_with_time_zone(patient.birth_date_on, I18n.t('date.formats.etb_short')), 
            age: "123", # OK
            national_id_number: patient.social_security_code,
            mother_name: '', # OK, hard-code
            sending_sms: 'FALSE', # OK
            treatment_sms: 'FALSE', # OK
            phone_number: '23711', # Hard-coded instead of [patient.phone]
            cellphone_number: '23711', # OK, just hard-code like this
            supervisor2_cellphone: '23711', # OK, just hard-code like this
            nationality: "national", 
            registration_address1: "address", # line đầu tiên của Contact Address
            registration_address2: '', # OK
            registration_region: 'MIỀN BẮC', # OK hard-coded
            registration_province: 'Hà Nội', # OK hard-coded
            registraiton_district: 'Cầu Giấy', # OK hard-coded
            located_at_different_address: 'TRUE', 
            current_address: "address", # lấy dòng đầu tiên của PERMANENT ADDRESS
            healthcare_unit_location: 'Miền Nam', # OK
            healthcare_unit_name: 'Quận 1', # OK
            healthcare_unit_registration_date: Extras::Dates::Format.datetime_with_time_zone(patient.created_at, I18n.t('date.formats.etb_short')), # ngày tạo patient
            suspect_mdr_case_type: 'failcatii',
            diagnosis_date: Extras::Dates::Format.datetime_with_time_zone(encounter.updated_at, I18n.t('date.formats.etb_short')), 
            tb_drug_resistance_type: 'mono', # LIST VALUE
            registration_group: 'VN_2015_OTHER', # @TODO
            site_of_disease: 'pulmonary_tuberculosis', 
            number_of_previous_tb_treatment: '0',
            consulting_date: Extras::Dates::Format.datetime_with_time_zone(patient.created_at, I18n.t('date.formats.etb_short')), 
            consulting_professional: '[FROM CDP]',
            consulting_height: '',
            consulting_weight: '100',
            consulting_comment: '',
            test_order: 'test_order'
          }
    }.to_json
  end

  before(:example) do
    episode = patient.episodes.make
    allow(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(xpert_result).and_return(json)
    allow(CdxVietnam::Presenters::Vtm).to receive(:create_patient).with(xpert_result).and_return(json)
    allow(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(microscopy_result).and_return(json)
    allow(CdxVietnam::Presenters::Vtm).to receive(:create_patient).with(microscopy_result).and_return(json)
    # allow(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(microscopy_result).and_return(json)
    allow(IntegrationJob).to receive(:perform_later).with(json).and_return(true)
    microscopy_result.reload
    xpert_result.reload
  end

  it " must not sync uncomplete test result" do
    expect(CdxVietnam::Presenters::Vtm).to receive(:create_patient).with(xpert_result).exactly(0).times
    expect(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(xpert_result).exactly(0).times
    xpert_result.save
    expect(CdxVietnam::Presenters::Vtm).to receive(:create_patient).with(microscopy_result).exactly(0).times
    expect(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(microscopy_result).exactly(0).times
    microscopy_result.save
  end

  context "in case not have old completed xpert result with rifampicin detected," do
    it " xpert result with completed without xpert rifampicin detected status must sync to vtm" do
      xpert_result.result_status = 'completed'
      expect(CdxVietnam::Presenters::Vtm).to receive(:create_patient).with(xpert_result).exactly(1).times
      expect(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(xpert_result).exactly(0).times
      xpert_result.save
    end

    it " xpert result with completed xpert rifampicin detected status must sync to etb" do
      xpert_result.tuberculosis = 'detected'
      xpert_result.rifampicin = 'detected'
      xpert_result.result_status = 'completed'
      expect(CdxVietnam::Presenters::Vtm).to receive(:create_patient).with(xpert_result).exactly(0).times
      expect(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(xpert_result).exactly(1).times
      xpert_result.save
    end

    it " microscopy result with completed without xpert rifampicin detected status must sync to vtm" do
      microscopy_result.result_status = 'completed'
      expect(CdxVietnam::Presenters::Vtm).to receive(:create_patient).with(microscopy_result).exactly(1).times
      expect(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(microscopy_result).exactly(0).times
      microscopy_result.save
    end

    it " xpert result with completed xpert rifampicin detected status must trigger completed microscopy result to etb" do
      microscopy_result.result_status = 'completed'
      microscopy_result.save
      xpert_result.tuberculosis = 'detected'
      xpert_result.rifampicin = 'detected'
      xpert_result.result_status = 'completed'
      expect(CdxVietnam::Presenters::Vtm).to receive(:create_patient).with(xpert_result).exactly(0).times
      expect(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(xpert_result).exactly(1).times
      expect(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(microscopy_result).exactly(1).times
      xpert_result.save
    end
  end

  context "is case have one or more old completed xpert rifampicin detected status," do
    let(:pre_xpert_result)          { XpertResult.make encounter: pre_encounter, tuberculosis: 'detected', result_at: 3.days.ago, result_name: 'xpertmtb', result_status: 'completed', rifampicin: 'detected' }

    before(:example) do
      pre_xpert_result.result_status = 'completed'
      pre_xpert_result.is_sync = true
      pre_xpert_result.save
    end

    it " xpert result with completed without xpert rifampicin detected status must sync to etb" do
      xpert_result.result_status = 'completed'
      expect(CdxVietnam::Presenters::Vtm).to receive(:create_patient).with(xpert_result).exactly(0).times
      expect(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(xpert_result).exactly(1).times
      xpert_result.save
    end

    it " xpert result with completed xpert rifampicin detected status must sync to etb" do
      xpert_result.tuberculosis = 'detected'
      xpert_result.rifampicin = 'detected'
      xpert_result.result_status = 'completed'
      expect(CdxVietnam::Presenters::Vtm).to receive(:create_patient).with(xpert_result).exactly(0).times
      expect(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(xpert_result).exactly(1).times
      xpert_result.save
    end

    it " microscopy result with completed status must sync to etb" do
      microscopy_result.result_status = 'completed'
      expect(CdxVietnam::Presenters::Vtm).to receive(:create_patient).with(microscopy_result).exactly(0).times
      expect(CdxVietnam::Presenters::Etb).to receive(:create_patient).with(microscopy_result).exactly(1).times
      microscopy_result.save
    end
  end

end
