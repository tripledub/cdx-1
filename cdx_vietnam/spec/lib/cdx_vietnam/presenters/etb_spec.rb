require 'spec_helper'

describe CdxVietnam::Presenters::Etb do
  let(:current_user)        { User.make }
  let(:institution)         { Institution.make(user_id: current_user.id) }
  let(:site)                { Site.make(institution: institution) }
  let(:patient)             { Patient.make institution: institution, gender: 'male' }
  let(:encounter)           { Encounter.make institution: institution, user: current_user, patient: patient }
  let(:xpert_result)        { XpertResult.make encounter: encounter, tuberculosis: 'indeterminate', result_at: 3.days.ago }

  context "must" do
    before(:each) do
      episode = patient.episodes.make
    end
    
    it "responds with JSON string" do
      json = CdxVietnam::Presenters::Etb.create_patient(xpert_result)
      expect(check_json_string(json)).to eq(true)
    end

    it "have patient field and test_order, target_system in patient field" do
      json = CdxVietnam::Presenters::Etb.create_patient(xpert_result)
      json = JSON.parse(json)
      patient_field = json['patient']
      expect(patient_field.nil?).to eq(false)
      expect(patient_field['test_order'].nil?).to eq(false)
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