require 'spec_helper'

describe CdxVietnam::Presenters::Vtm do
  let(:current_user)        { User.make }
  let(:institution)         { Institution.make(user_id: current_user.id) }
  let(:site)                { Site.make(institution: institution) }
  let(:patient)             { Patient.make institution: institution, gender: 'male' }
  let(:encounter)           { Encounter.make institution: institution, user: current_user, patient: patient }
  let(:xpert_result)        { XpertResult.make encounter: encounter, tuberculosis: 'indeterminate', result_at: 3.days.ago, result_name: 'xpertmtb' }
  let(:patient2)            { Patient.make institution: institution, gender: 'male', nationality: 'native' }
  let(:encounter2)          { Encounter.make institution: institution, user: current_user, patient: patient2, coll_sample_type: 'SPUTUM' }
  let(:microscopy_result)   { MicroscopyResult.make encounter: encounter2, result_at: 1.day.ago, result_name: 'microscopy' }
  let(:address1)            { patient2.addresses.make(address: '1 street', city: 'london', country: "asd", zip_code: 'sw11') }
  let(:address2)            { patient2.addresses.make(address: '2 street', city: 'london', country: "asd", zip_code: 'sw11') }

  def check_json_string(json_string)
    begin
      JSON.parse(json_string)
    rescue
      return false
    end
    return true
  end

  context "xpert result must" do
    before(:example) do
      episode = patient.episodes.make
      @json = CdxVietnam::Presenters::Vtm.create_patient(xpert_result)
    end
    it "responds with JSON string" do
      expect(check_json_string(@json)).to eq(true)
    end

    it "have patient field and test_order, target_system in patient field" do
      jsonx = JSON.parse(@json)
      patient_field = jsonx['patient']
      expect(patient_field.nil?).to eq(false)
      expect(patient_field['test_order'].nil?).to eq(false)
      test_order = patient_field['test_order']
      expect(test_order['type'].to_s).to eq('xpert')
      expect(patient_field['target_system'].nil?).to eq(false)
    end

    it "return right xpert result with rifampicin detected" do
      xpert_result.tuberculosis = 'detected'
      xpert_result.rifampicin = 'detected'
      xpert_result.save
      json = CdxVietnam::Presenters::Vtm.create_patient(xpert_result)
      json = JSON.parse(json)
      expect(json['patient']['test_order']['result']).to eq(3)
    end

    it "return right xpert result with rifampicin not detected" do
      xpert_result.tuberculosis = 'detected'
      xpert_result.rifampicin = 'not_detected'
      xpert_result.save
      json = CdxVietnam::Presenters::Vtm.create_patient(xpert_result)
      json = JSON.parse(json)
      expect(json['patient']['test_order']['result']).to eq(2)
    end

  end

  context "microscopy result must" do
    before(:example) do
      episode = patient2.episodes.make
      address1.reload
      address2.reload
      @json = CdxVietnam::Presenters::Vtm.create_patient(microscopy_result)
    end

    it "responds with JSON string" do
      expect(check_json_string(@json)).to eq(true)
    end

    context "have" do
      let(:encounter2)  { Encounter.make institution: institution, user: current_user, patient: patient2, coll_sample_type: 'OTHER' }
      before(:example) do
        json = JSON.parse(@json)
        @patient_field = json['patient']
      end

      it "patient field and test_order, target_system in patient field" do
        expect(@patient_field.nil?).to eq(false)
      end

      it "test order field in patient field" do
        expect(@patient_field['test_order'].nil?).to eq(false)
      end

      it "target system field in patient field" do
        expect(@patient_field['target_system'].nil?).to eq(false)
      end
    end
  end

end