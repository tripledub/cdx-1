require 'spec_helper'
require 'policy_spec_helper'

describe TestResultsController do
  let!(:user)             { User.make }
  let!(:institution)      { user.create Institution.make_unsaved }
  let(:site)              { Site.make institution: institution }
  let(:subsite)           { Site.make institution: institution, parent: site }
  let(:patient)           { Patient.make institution: institution }
  let(:device)            { Device.make institution_id: institution.id, site: site }
  let(:site2)             { Site.make institution: institution }
  let(:device2)           { Device.make institution_id: institution.id, site: site2 }
  let(:encounter)         { Encounter.make institution: institution , user: user, patient: patient }
  let(:other_user)        { User.make }
  let(:other_institution) { Institution.make user_id: other_user.id }
  let(:other_site)        { Site.make institution: other_institution }
  let(:other_device)      { Device.make institution_id: other_institution.id, site: other_site }
  let(:default_params)    { { context: institution.uuid } }
  let!(:test_results) do
    4.times do
      TestResult.make patient: patient, institution: institution, device: device
    end

    2.times do
      MicroscopyResult.make encounter: encounter
    end

    5.times do
      CultureResult.make encounter: encounter
    end

    3.times do
      DstLpaResult.make encounter: encounter
    end

    2.times do
      XpertResult.make encounter: encounter, serial_number: '9999239999'
    end
  end

  before :each do
    sign_in user
  end

  it "should display an empty page when there are no test results" do
    response = get :index

    expect(response.status).to eq(200)
  end

  it "should list test results" do
    get :index

    expect(response).to be_success
    expect(assigns(:total)).to eq(4)
  end

  describe 'tabs' do
    it 'should return xpert test results only' do
      get :index, test_results_tabs_selected_tab: 'xpert'

      expect(assigns(:total)).to eq(2)
    end

    it 'should return culture test results only' do
      get :index, test_results_tabs_selected_tab: 'culture'

      expect(assigns(:total)).to eq(5)
    end
  end

  describe 'filters' do
    it 'should return tests filtered by serial number' do
      get :index, test_results_tabs_selected_tab: 'xpert', 'sample.id' => '23'

      expect(assigns(:total)).to eq(2)
    end
  end

  describe 'scoping' do
    it 'should show all tests for institution' do
      user.update_attribute(:last_navigation_context, institution.uuid)
      get :index, context: site.uuid

      expect(assigns(:total)).to eq(4)
    end

    it 'should show all tests for site' do
      user.update_attribute(:last_navigation_context, site.uuid)
      device2 = Device.make institution_id: institution.id, site: subsite
      TestResult.make device: device2
      get :index, context: site.uuid + '-*'

      expect(assigns(:total)).to eq(5)
    end

    it 'with exclusion should show only tests for site, not subsites' do
      device2 = Device.make institution_id: institution.id, site: subsite
      3.times do
        TestResult.make device: device2
      end
      get :index, context: site.uuid + '-!'

      expect(assigns(:total)).to eq(4)
    end
  end

  describe "loading entities" do
    before(:each) do
      other_user; other_institution; other_site; other_device
      subsite; site2; device2
      TestResult.make(
        core_fields: {"assays" =>["condition" => "mtb", "result" => :positive]},
        device_messages: [ DeviceMessage.make(device: device) ])
    end

    it "should load for filters" do
      get :index

      expect(response).to be_success
      expect(assigns(:sites).to_a).to contain_exactly(site, site2, subsite)
      expect(assigns(:devices).to_a).to contain_exactly(device, device2)
    end

    it "should load for filters scoped by context" do
      get :index, context: site.uuid

      expect(response).to be_success
      expect(assigns(:sites).to_a).to contain_exactly(site, subsite)
      expect(assigns(:devices).to_a).to contain_exactly(device)
    end
  end

  describe "CSV" do
    let!(:patient) do
      Patient.make(
        institution: institution,
        core_fields: { "gender" => "male" },
        custom_fields: { "custom" => "patient value" },
        plain_sensitive_data: { "name" => "Doe" }
      )
    end
    let!(:encounter) do
      Encounter.make(
        institution: institution,
        patient: patient,
        core_fields: {
          "patient_age" => { "years" => 12 },
          "diagnosis" => [
            "name" => "mtb",
            "condition" => "mtb",
            "result" => "positive"
          ]
        },
        custom_fields: { "custom" => "encounter value" },
        plain_sensitive_data: { "observations" => 'HIV POS' }
      )
    end
    let!(:sample) do
      Sample.make(
        institution: institution,
        encounter: encounter,
        patient: patient,
        core_fields: { "type" => "blood" },
        custom_fields: { "custom" => "sample value" }
      )
    end
    let!(:sample_id) { sample.sample_identifiers.make }
    let!(:test) do
      TestResult.make_from_sample(
        sample,
        device: device,
        core_fields: {
          "name" => "test1", "error_description" => "No error",
          "assays" => [
            { "condition" => "mtb", "result" => "positive", "name" => "mtb" },
            { "condition" => "flu", "result" => "negative", "name" => "flu" }
          ]
        },
        custom_fields: { "custom_a" => "test value 1" }
      ).tap { |t| TestResultIndexer.new(t).index(true) }
    end

    let(:csv) { CSV.parse(response.body, headers: true) }

    RSpec::Matchers.define :contain_field do |name, value|
      match do |csv_row|
        if value.blank?
          csv_row[name].blank?
        else
          csv_row[name] == value
        end
      end
      failure_message do |csv_row|
        "expected '#{name}' to eq '#{value}', got '#{csv_row[name]}'\nrow: #{csv_row.inspect}"
      end
    end

    context "single test" do
      before(:each) do
        get :index, format: :csv
      end

      it "should be successful" do
        expect(response).to be_success
      end

      it "should download all the tests" do
        expect(csv.size).to eq(5)
      end
    end

    context 'xpert results csv' do
      it 'should generate a csv result' do
        get :index, test_results_tabs_selected_tab: 'xpert', format: :csv

        expect(CSV.parse(response.body).size).to eq(3)
      end
    end

    context 'microscopy results csv' do
      it 'should generate a csv result' do
        get :index, test_results_tabs_selected_tab: 'microscopy', format: :csv

        expect(CSV.parse(response.body).size).to eq(3)
      end
    end

    context 'dst results csv' do
      it 'should generate a csv result' do
        get :index, test_results_tabs_selected_tab: 'dst_lpa', format: :csv

        expect(CSV.parse(response.body).size).to eq(4)
      end
    end

    context 'culture results csv' do
      it 'should generate a csv result' do
        get :index, test_results_tabs_selected_tab: 'culture', format: :csv

        expect(CSV.parse(response.body).size).to eq(6)
      end
    end
  end

  describe 'show single test result' do
    let(:test_result) { TestResult.first }

    before :each do
      sign_in user
    end

    it 'should authorize user with access to device' do
      get :show, id: test_result.id

      expect(assigns(:test_result)).to eq(test_result)
      expect(response).to be_success
    end

    it 'should authorize user with access to site' do
      get :show, id: test_result.id

      expect(assigns(:test_result)).to eq(test_result)
      expect(response).to be_success
    end

    it "should authorize user with access to institution" do
      get :show, id: test_result.id

      expect(assigns(:test_result)).to eq(test_result)
      expect(response).to be_success
    end

    context "when original site was moved (ie soft deleted + device changed)" do
      let!(:new_site) { Site.make institution: institution }

      before(:each) {
        device.site = new_site
        device.save!

        site.destroy!
      }

      it "should authorize user with access to device" do
        get :show, id: test_result.id

        expect(assigns(:test_result)).to eq(test_result)
        expect(response).to be_success
      end

      it "should authorize user with access to institution" do
        get :show, id: test_result.id

        expect(assigns(:test_result)).to eq(test_result)
        expect(response).to be_success
      end
    end
  end
end
