require 'spec_helper'

describe CdxVietnam::Presenters::Etb do
  let(:current_user)        { User.make }
  let(:institution)         { Institution.make(user_id: current_user.id) }
  let(:site)                { Site.make(institution: institution) }
  let(:patient)             { Patient.make institution: institution, gender: 'male' }
  let(:encounter)           { Encounter.make institution: institution, user: current_user, patient: patient }
  let(:xpert_result)        { XpertResult.make encounter: encounter, tuberculosis: 'indeterminate', result_at: 3.days.ago }
  let(:patient2)            { Patient.make institution: institution, gender: 'male', nationality: 'native' }
  let(:encounter2)          { Encounter.make institution: institution, user: current_user, patient: patient2 }
  let(:microscopy_result)   { MicroscopyResult.make encounter: encounter2, result_at: 1.day.ago }

  context "xpert result must" do
    before(:example) do
      episode = patient.episodes.make
      @json = CdxVietnam::Presenters::Etb.create_patient(xpert_result)
    end

    it "responds with JSON string" do
      expect(check_json_string(@json)).to eq(true)
    end

    it "have patient field and test_order, target_system in patient field" do
      jsonx = JSON.parse(@json)
      patient_field = jsonx['patient']
      expect(patient_field.nil?).to eq(false)
      expect(patient_field['test_order'].nil?).to eq(false)
      expect(patient_field['target_system'].nil?).to eq(false)
    end
  end

  context "microscopy result must" do
    before(:example) do
      episode = patient2.episodes.make
      @json = CdxVietnam::Presenters::Etb.create_patient(microscopy_result)
    end
    
    it "responds with JSON string" do
      expect(check_json_string(@json)).to eq(true)
    end

    context "have" do
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

def check_json_string(json_string)
  begin
    JSON.parse(json_string)
  rescue
    return false
  end
  return true
end