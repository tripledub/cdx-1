require 'spec_helper'
require 'policy_spec_helper'

RSpec.describe PatientsController, type: :controller do
  let!(:institution) {Institution.make}
  let!(:user)        {institution.user}
  before(:each) {sign_in user}
  let(:default_params) { {context: institution.uuid} }

  let!(:other_user) { Institution.make.user }
  before(:each) {
    grant user, other_user, institution, READ_INSTITUTION
  }

  context "index" do
    it "should be accessible by institution owner" do
      get :index
      expect(response).to be_success
    end

    it "should list patients if can read" do
      institution.patients.make
      get :index
      expect(assigns(:patients).count).to eq(1)
    end

    it "should ignore phantom patients" do
      institution.patients.make :phantom
      get :index

      expect(assigns(:patients).count).to eq(0)
    end

    it "should not list patients if can not read" do
      institution.patients.make
      sign_in other_user
      get :index
      expect(assigns(:patients).count).to eq(0)
    end

    it "can create if admin" do
      get :index

      expect(response.body).to include 'Add patient'
    end

    it "can create if allowed" do
      grant user, other_user, institution, CREATE_INSTITUTION_PATIENT
      sign_in other_user
      get :index

      expect(response.body).to include 'Add patient'
    end

    it "can not create if not allowed" do
      sign_in other_user
      get :index

      expect(response.body).to_not include 'Add patient'
    end

    it "should filter by name" do
      institution.patients.make name: 'John'
      institution.patients.make name: 'Clark'
      institution.patients.make name: 'Mery johana'

      get :index, name: 'jo'
      expect(response).to be_success
      expect(assigns(:patients).count).to eq(2)
    end

    it "should filter by entity_id" do
      institution.patients.make entity_id: '10110'
      institution.patients.make entity_id: '21100'
      institution.patients.make entity_id: '40440'

      get :index, entity_id: '11'
      expect(response).to be_success
      expect(assigns(:patients).count).to eq(2)
    end

    it "should filter based con navigation_context site" do
      site1 = institution.sites.make
      site11 = Site.make :child, parent: site1
      site2 = institution.sites.make

      patient1 = institution.patients.make
      patient2 = institution.patients.make

      patient1.encounters.make site: site11
      patient2.encounters.make site: site2

      get :index, context: site1.uuid

      expect(response).to be_success
      expect(assigns(:patients).to_a).to eq([patient1])
    end

    it "should filter based con navigation_context site if no encounter" do
      site1 = institution.sites.make
      site11 = Site.make :child, parent: site1
      site2 = institution.sites.make

      patient1 = institution.patients.make site: site11
      patient2 = institution.patients.make site: site2

      get :index, context: site1.uuid

      expect(response).to be_success
      expect(assigns(:patients).to_a).to eq([patient1])
    end
  end

  context "show" do
    let!(:patient) { institution.patients.make }

    it "should be accessible be institution owner" do
      get :show, id: patient.id
      expect(response).to be_success
    end

    it "should not be accessible if can not read" do
      sign_in other_user
      get :show, id: patient.id
      expect(response).to be_forbidden
    end

    it "should be accessible if can read" do
      grant user, other_user, Patient, READ_PATIENT
      sign_in other_user
      get :show, id: patient.id
      expect(response).to be_success
    end

    it "should allow to edit if can update" do
      grant user, other_user, Patient, READ_PATIENT
      grant user, other_user, Patient, UPDATE_PATIENT
      sign_in other_user
      get :show, id: patient.id
      expect(response).to be_success
    end
  end

  context "new" do
    it "should be accessible be institution owner" do
      get :new
      expect(response).to be_success
    end

    it "should be allowed it can create" do
      grant user, other_user, institution, CREATE_INSTITUTION_PATIENT
      sign_in other_user
      get :new
      expect(response).to be_success
    end

    it "should not be allowed it can not create" do
      sign_in other_user
      get :new
      expect(response).to be_forbidden
    end

    it "should preserve next_url" do
      next_url = 'http://example.org/some_next_url'
      get :new, next_url: next_url
      expect(response.body).to include(next_url)
    end
  end

  context "create" do
    let(:patient_form_plan) {
      { name: 'Lorem', entity_id: '1001', gender: 'female', 'birth_date_on(1i)': '2000', 'birth_date_on(2i)': '1', 'birth_date_on(3i)': '18' }
    }

    let(:patient_form_plan_birth_date_on) { Date.new(2000, 1, 18) }

    def build_patient_form_plan(options)
      patient_form_plan.dup.merge! options
    end

    it "should create new patient in context institution" do
      expect {
        post :create, patient: patient_form_plan
      }.to change(institution.patients, :count).by(1)

      expect(response).to redirect_to patient_path(Patient.last)
    end

    it "should save fields" do
      post :create, patient: patient_form_plan
      patient = institution.patients.last

      expect(patient.name).to eq(patient_form_plan[:name])
      expect(patient.entity_id).to eq(patient_form_plan[:entity_id])
      expect(patient.gender).to eq(patient_form_plan[:gender])
      expect(patient.birth_date_on).to eq(patient_form_plan_birth_date_on)

      expect(patient.address).to eq(patient_form_plan[:address])
      expect(patient.city).to eq(patient_form_plan[:city])
      expect(patient.state).to eq(patient_form_plan[:state])
      expect(patient.zip_code).to eq(patient_form_plan[:zip_code])

      expect(patient.plain_sensitive_data['name']).to eq(patient_form_plan[:name])
      expect(patient.core_fields['gender']).to eq(patient_form_plan[:gender])
      expect(patient.plain_sensitive_data['id']).to eq(patient_form_plan[:entity_id])
    end

    it "should save it as non phantom" do
      post :create, patient: patient_form_plan
      patient = institution.patients.last
      expect(patient).to_not be_phantom
    end

    it "should create new patient in context institution if allowed" do
      grant user, other_user, institution, CREATE_INSTITUTION_PATIENT
      sign_in other_user

      expect {
        post :create, patient: patient_form_plan
      }.to change(institution.patients, :count).by(1)
    end

    it "should not create new patient in context institution if not allowed" do
      sign_in other_user

      expect {
        post :create, patient: patient_form_plan
      }.to change(institution.patients, :count).by(0)

      expect(response).to be_forbidden
    end

    it "should require name" do
      expect {
        post :create, patient: build_patient_form_plan(name: '')
      }.to change(institution.patients, :count).by(0)

      expect(assigns(:patient).errors).to have_key(:name)
      expect(response).to render_template("patients/new")
    end

    it "should require entity_id" do
      expect {
        post :create, patient: build_patient_form_plan(entity_id: '')
      }.to change(institution.patients, :count).by(0)

      expect(assigns(:patient).errors).to have_key(:entity_id)
      expect(response).to render_template("patients/new")
    end

    it "should validate entity_id uniqness" do
      institution.patients.make entity_id: '1001', name: 'Bruce McLaren'

      expect {
        post :create, patient: build_patient_form_plan(entity_id: '1001')
      }.to change(institution.patients, :count).by(0)

      expect(assigns(:patient).errors).to have_key(:entity_id)
      expect(response).to render_template("patients/new")
    end

    it "should not require birth_date_on" do
      expect {
        post :create, patient: { name: 'Lorem', entity_id: '1001', gender: 'female' }
      }.to change(institution.patients, :count).by(1)

      patient = institution.patients.first
      expect(patient.birth_date_on).to be_nil
      expect(patient.plain_sensitive_data).to_not have_key('birth_date_on')
    end

    it "should validate gender" do
      expect {
        post :create, patient: build_patient_form_plan(gender: 'invalid-value')
      }.to change(institution.patients, :count).by(0)

      expect(assigns(:patient).errors).to have_key(:gender)
      expect(response).to render_template("patients/new")
    end

    it "should not require gender" do
      expect {
        post :create, patient: build_patient_form_plan(gender: '')
      }.to change(institution.patients, :count).by(1)

      patient = institution.patients.first
      expect(patient.gender).to be_nil
      expect(patient.core_fields).to_not have_key('gender')
    end

    it "should use navigation_context as patient site" do
      site = institution.sites.make
      expect {
        post :create, context: site.uuid, patient: patient_form_plan
      }.to change(institution.patients, :count).by(1)

      expect(Patient.last.site).to eq(site)

      expect(response).to be_redirect
    end

    it "should preserve next_url" do
      next_url = 'http://example.org/some_next_url'
      post :create, patient: build_patient_form_plan(name: ''), next_url: next_url

      expect(assigns(:patient).errors).to have_key(:name)
      expect(response).to render_template("patients/new")
      expect(response.body).to include(next_url)
    end

    it "should redirects to next_url on creation with patient_id" do
      next_url = 'http://example.org/some_next_url?foo=bar'
      post :create, patient: build_patient_form_plan({}), next_url: next_url

      patient = Patient.last
      expect(response).to redirect_to "#{next_url}&patient_id=#{patient.id}"
    end
  end

  context "edit" do
    let!(:patient) { institution.patients.make }

    it "should be accessible by institution owner" do
      get :edit, id: patient.id
      expect(response).to be_success
      expect(assigns(:can_delete)).to be_truthy
    end

    it "should be accessible if can edit" do
      grant user, other_user, Patient, UPDATE_PATIENT
      sign_in other_user

      get :edit, id: patient.id
      expect(response).to be_success
      expect(assigns(:can_delete)).to be_falsy
    end

    it "should not be accessible if can not edit" do
      sign_in other_user

      get :edit, id: patient.id
      expect(response).to be_forbidden
    end

    it "should allow to delete if can delete" do
      grant user, other_user, Patient, UPDATE_PATIENT
      grant user, other_user, Patient, DELETE_PATIENT
      sign_in other_user

      get :edit, id: patient.id
      expect(response).to be_success
      expect(assigns(:can_delete)).to be_truthy
    end
  end

  context "update" do
    let(:patient) { institution.patients.make }

    xit "should update existing patient" do
      post :update, id: patient.id, patient: { name: 'Lorem', gender: 'female', 'birth_date_on(1i)': '2000', 'birth_date_on(2i)': '1', 'birth_date_on(3i)': '18', address: "1 street", city: 'london', state: "aa", zip_code: 'sw11' }
      expect(response).to be_redirect

      patient.reload
      expect(patient.name).to eq("Lorem")
      expect(patient.gender).to eq("female")
      expect(patient.birth_date_on).to eq(Date.new(2000, 1, 18))
      expect(patient.address).to eq("1 street")
      expect(patient.city).to eq("london")
      expect(patient.state).to eq("aa")
      expect(patient.zip_code).to eq("sw11")
    end

    it 'should log the updates' do
      post :update, id: patient.id, patient: { name: 'Lorem', gender: 'female', 'birth_date_on(1i)': '2000', 'birth_date_on(2i)': '1', 'birth_date_on(3i)': '18', address: "1 street", city: 'london', state: "aa", zip_code: 'sw11' }
      audit_update = patient.audit_logs.last.audit_updates.first
    end

    it "should assign entity_id if previous is blank" do
      patient                = institution.patients.make :phantom
      patient.entity_id      = nil
      patient.entity_id_hash = nil
      patient.save(validate: false)

      expect(patient.entity_id).to be_blank
      expect(patient.entity_id_hash).to be_blank
      post :update, id: patient.id, patient: { name: 'Lorem', gender: 'female', 'birth_date_on(1i)': '2000', 'birth_date_on(2i)': '1', 'birth_date_on(3i)': '18', entity_id: 'other-id' }
      expect(response).to be_redirect

      patient.reload
      expect(patient.entity_id).to eq('other-id')
      expect(patient.entity_id_hash).to_not be_blank
      expect(patient.plain_sensitive_data['id']).to eq('other-id')

      expect(patient).to_not be_phantom
    end

    it "should not change entity_id from previous" do
      old_entity_id = patient.entity_id
      expect(patient.entity_id).to_not be_blank
      post :update, id: patient.id, patient: { name: 'Lorem', gender: 'female', 'birth_date_on(1i)': '2000', 'birth_date_on(2i)': '1', 'birth_date_on(3i)': '18', entity_id: 'other-id' }
      expect(assigns(:patient).errors).to have_key(:entity_id)
      expect(response).to render_template("patients/edit")

      patient.reload
      expect(patient.entity_id).to eq(old_entity_id)
      expect(patient.plain_sensitive_data['id']).to eq(old_entity_id)
    end

    it "should not remove entity_id from previous" do
      old_entity_id = patient.entity_id
      expect(patient.entity_id).to_not be_blank
      post :update, id: patient.id, patient: { name: 'Lorem', gender: 'female', 'birth_date_on(1i)': '2000', 'birth_date_on(2i)': '1', 'birth_date_on(3i)': '18', entity_id: '' }

      expect(assigns(:patient).errors).to have_key(:entity_id)
      expect(response).to render_template("patients/edit")
      expect(patient.entity_id).to eq(old_entity_id)
      expect(patient.plain_sensitive_data['id']).to eq(old_entity_id)
    end

    it "should require name" do
      post :update, id: patient.id, patient: { name: '', 'birth_date_on(1i)': '2000', 'birth_date_on(2i)': '1', 'birth_date_on(3i)': '18' }

      expect(assigns(:patient).errors).to have_key(:name)
      expect(response).to render_template("patients/edit")
    end

    xit "should require entity_id" do
      patient = institution.patients.make :phantom
      post :update, id: patient.id, patient: { entity_id: '' }

      expect(assigns(:patient).errors).to_not have_key(:entity_id)
    end

    it "should update existing patient if allowed" do
      grant user, other_user, Patient, UPDATE_PATIENT

      sign_in other_user
      post :update, id: patient.id, patient: { name: 'Lorem', gender: 'female', 'birth_date_on(1i)': '2000', 'birth_date_on(2i)': '1', 'birth_date_on(3i)': '18' }
      expect(response).to be_redirect

      patient.reload
      expect(patient.name).to eq("Lorem")
      expect(patient.gender).to eq("female")
      expect(patient.birth_date_on).to eq(Date.new(2000, 1, 18))
    end

    it "should not update existing patient if allowed" do
      sign_in other_user
      post :update, id: patient.id, patient: { name: 'Lorem', 'birth_date_on(1i)': '2000', 'birth_date_on(2i)': '1', 'birth_date_on(3i)': '18' }
      expect(response).to be_forbidden

      patient.reload
      expect(patient.name).to_not eq("Lorem")
    end
  end

  context "destroy" do
    let!(:patient) { institution.patients.make }

    it "should be able to soft delete a patient" do
      expect {
        delete :destroy, id: patient.id
      }.to change(institution.patients, :count).by(-1)

      patient.reload
      expect(patient.deleted_at).to_not be_nil

      expect(response).to be_redirect
    end

    it "should be able to delete if can delete" do
      grant user, other_user, Patient, DELETE_PATIENT
      sign_in other_user

      expect {
        delete :destroy, id: patient.id
      }.to change(institution.patients, :count).by(-1)

      patient.reload
      expect(patient.deleted_at).to_not be_nil
    end

    it "should not able to delete if can delete" do
      sign_in other_user

      expect {
        delete :destroy, id: patient.id
      }.to change(institution.patients, :count).by(0)

      expect(response).to be_forbidden
    end
  end

  context "search" do
    it "should search in entire institution" do
      site1 = institution.sites.make
      site2 = institution.sites.make
      other_institution = Institution.make user: user

      patient1 = institution.patients.make name: 'john doe', site: site1
      patient2 = institution.patients.make name: 'john foo', site: site2
      other_institution.patients.make name: 'john alone'

      get :search, q: 'john', context: site1.uuid

      json_response = JSON.parse(response.body)
      expect(json_response.map { |p| p["id"] }).to match([patient1.id, patient2.id])
    end
  end
end
