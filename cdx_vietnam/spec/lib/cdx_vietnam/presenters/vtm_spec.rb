require 'spec_helper'

describe CdxVietnam::Presenters::Vtm do
  let(:current_user)        { User.make }
  let(:institution)         { Institution.make(user_id: current_user.id) }
  let(:site)                { Site.make(institution: institution) }
  let(:patient)             { Patient.make institution: institution, gender: 'male' }
  let(:encounter)           { Encounter.make institution: institution, user: current_user, patient: patient }
  let(:microscopy_result)   { MicroscopyResult.make encounter: encounter, result_at: 1.day.ago, result_name: 'microscopy' }
  let(:patient2)            { Patient.make institution: institution, gender: 'male', nationality: 'native' }
  let(:encounter2)          { Encounter.make institution: institution, user: current_user, patient: patient2 }
  let(:xpert_result)        { XpertResult.make encounter: encounter2, tuberculosis: 'indeterminate', result_at: 3.days.ago, result_name: 'xpertmtb' }


  context "microscopy result must" do
    it "responds with JSON string" do
      episode = patient.episodes.make
      json = CdxVietnam::Presenters::Vtm.create_patient(microscopy_result)
      expect(check_json_string(json)).to eq(true)
    end

    it "have patient field and test_order, target_system in patient field" do
      episode = patient.episodes.make
      json = CdxVietnam::Presenters::Vtm.create_patient(microscopy_result)
      json = JSON.parse(json)
      patient_field = json['patient']
      expect(patient_field.nil?).to eq(false)
      expect(patient_field['test_order'].nil?).to eq(false)
      test_order = patient_field['test_order']
      expect(test_order['type'].to_s).to eq('microscopy')
      expect(patient_field['target_system'].nil?).to eq(false)
    end
  end

  context "xpert result must" do
    it "responds with JSON string" do
      episode = patient.episodes.make
      json = CdxVietnam::Presenters::Vtm.create_patient(xpert_result)
      expect(check_json_string(json)).to eq(true)
    end

    it "have patient field and test_order, target_system in patient field" do
      episode = patient.episodes.make
      json = CdxVietnam::Presenters::Vtm.create_patient(xpert_result)
      json = JSON.parse(json)
      patient_field = json['patient']
      expect(patient_field.nil?).to eq(false)
      expect(patient_field['test_order'].nil?).to eq(false)
      test_order = patient_field['test_order']
      expect(test_order['type'].to_s).to eq('xpert')
      expect(patient_field['target_system'].nil?).to eq(false)
    end
  end

end

def check_json_string(json_string)
  begin
    JSON.parse(json_string)
  rescue
    return false
  end
  return true
end