require 'spec_helper'
require "#{Rails.root}/cdx_core/spec/policy_spec_helper"

describe CdxApiCore::EncountersController, elasticsearch: true, validate_manifest: false do

  let(:user) { User.make }
  let!(:institution) { Institution.make user_id: user.id }
  let(:site) { Site.make institution: institution }
  let(:device) { Device.make institution: institution, site: site }
  let(:data) { Oj.dump test:{assays: [result: :positive]} }

  before(:each) { sign_in user }

  def get_updates(options, body="")
    refresh_index
    response = get :index, body, options.merge(format: 'json')
    expect(response.status).to eq(200)
    Oj.load(response.body)["encounters"]
  end

  context "Query" do
    context "Policies" do
      it "allows a user to query encounters of it's own institutions" do
        device2 = Device.make

        DeviceMessage.create_and_process device: device, plain_text_data: (Oj.dump test:{assays:[{name: "mtb", result: :positive}]}, encounter: {patient_age: Cdx::Field::DurationField.years(10)})
        DeviceMessage.create_and_process device: device2, plain_text_data: (Oj.dump test:{assays:[{name: "mtb", result: :negative}]}, encounter: {patient_age: Cdx::Field::DurationField.years(20)})

        refresh_index

        response = get_updates 'institution.id' => institution.id
        expect(response.size).to eq(0)
      end
    end
  end

  context "Schema" do
    it "should return the encounters schema" do
      get :schema, locale: 'es-AR', format: 'json'
      expect(response).to be_success
      schema = Oj.load(response.body)
      expect(schema.keys).to contain_exactly('$schema', 'type', 'title', 'properties')
      expect(schema['title']).to eq('es-AR')
    end
  end

  context "Pii" do

    before(:each) do
      register_cdx_fields encounter: { fields: { case_sn: { pii: true } } }

      patient1 = Patient.make(
        institution: institution,
        core_fields: { "gender" => "male" },
        custom_fields: { "custom" => "patient value" },
        name: "Doe"
      )

      encounter1=
        Encounter.make(
          institution: institution,
          patient: patient1,
          core_fields: {
            "patient_age" => { "years" => 12 },
            "diagnosis" => [
              "name" => "mtb",
              "condition" => "mtb",
              "result" => "positive"
            ]
          },
          custom_fields: { "custom" => "encounter value" },
          plain_sensitive_data: { "observations": "HIV POS" }
        )

        DeviceMessage.create_and_process device: device, plain_text_data: Oj.dump(
          test: { assays:[{name: "mtb", result: :positive}] },
          encounter: encounter1.to_s)
    end

    let(:encounter) { Encounter.first }

    it "should return pii for institution owner" do
      expect(Encounter.count).to eq(1)

      get :pii, id: encounter.uuid

      expect(response).to be_success
      pii = Oj.load(response.body)
      expect(pii['uuid']).to eq(encounter.uuid)
      expect(pii['pii']['patient']['name']).to eq("Doe")
      expect(pii['pii']['encounter']['observations']).to eq("HIV POS")
    end

    context "permissions" do

      it "should not return pii if unauthorised" do
        expect(Encounter.count).to eq(1)

        other_user = User.make
        grant user, other_user, encounter, Policy::Actions::READ_ENCOUNTER
        sign_in other_user
        get :pii, id: encounter.uuid

        expect(response).to be_forbidden
      end

      it "should return pii if unauthorised" do
        expect(Encounter.count).to eq(1)

        other_user = User.make
        grant user, other_user, encounter, Policy::Actions::PII_ENCOUNTER
        sign_in other_user
        get :pii, id: encounter.uuid

        expect(response).to be_success
      end
    end
  end
end
