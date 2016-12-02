require 'spec_helper'

RSpec.describe EpisodesController, type: :controller do
  render_views
  let(:institution)    { Institution.make }
  let(:user)           { institution.user }
  let!(:site) { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution, site: site }
  let(:default_params) { { context: institution.uuid } }
  let(:valid_params) do
    {
      diagnosis: :presumptive_tb,
      initial_history: :previous,
      previous_history: :relapsed,
      drug_resistance: :mono,
      hiv_status: :unknown,
      anatomical_site_diagnosis: :preumpitve_tb,
      outcome: :cured
    }
  end
  let(:episode) { Episode.make(patient: patient) }

  before(:each) do
    sign_in user
  end

  describe '#index' do
    before :each do
      2.times { Episode.make patient: patient }
      5.times { Episode.make patient: patient, closed: true }
    end

    context 'open episodes' do
      before :each do
        get :index, patient_id: patient.id, status: '0'
      end

      it 'should return a json with all open episodes' do
        expect(JSON.parse(response.body).size).to eq(2)
      end
    end

    context 'closed episodes' do
      before :each do
        get :index, patient_id: patient.id, status: '1'
      end

      it 'should return a json with all open episodes' do
        expect(JSON.parse(response.body).size).to eq(5)
      end
    end
  end

  describe '#new' do
    before do
      get :new, patient_id: patient.id
    end

    it 'renders the :new view' do
      expect(response).to render_template(:new)
    end
  end

  describe '#edit' do
    before do
      get :edit, patient_id: patient.id, id: episode.id
    end

    it 'renders the :edit view' do
      expect(response).to render_template(:edit)
    end

    it 'assigns the :episode to the view' do
      expect(assigns(:episode)).to eq(episode)
    end
  end

  describe '#POST :create' do
    context 'with valid params' do
      before do
        post :create, patient_id: patient.id, episode: valid_params
      end

      it 'creates a new episode' do
        episode = patient.episodes.last
        expect(episode.diagnosis).to eq('presumptive_tb')
        expect(episode.initial_history).to eq('previous')
        expect(episode.previous_history).to eq('relapsed')
        expect(episode.drug_resistance).to eq('mono')
        expect(episode.hiv_status).to eq('unknown')
        expect(episode.outcome).to eq('cured')
      end

      it 'redirects to the patients :show page' do
        expect(response).to redirect_to patient_path(patient)
      end
    end

    context 'with invalid params' do
      before do
        valid_params.delete(:hiv_status)
        post :create, patient_id: patient.id, episode: valid_params
      end

      it 're-renders the :new action' do
        expect(response).to render_template(:new)
      end
    end

    describe 'auditing :create' do
      it 'gets logged in AuditLog' do
        expected = expect do
          post :create, patient_id: patient.id, episode: valid_params
        end
        expected.to change(AuditLog, :count).by(1)
      end
    end
  end

  describe '#PUT :update' do
    context 'with valid params' do
      let(:valid_params) { episode.attributes }
      before do
        valid_params['outcome'] = 'new_value'
        put :update, patient_id: patient.id, id: episode.id, episode: valid_params
      end

      it 'sets the new value(s)' do
        updated_episode = episode.reload
        expect(updated_episode.outcome).to eq('new_value')
      end

      it 'redirects to the patients :show page' do
        expect(response).to redirect_to patient_path(patient)
      end
    end

    describe 'auditing :create' do
      let(:expected) do
        expect do
          put :update, patient_id: patient.id,
                       id: episode.id,
                       episode: valid_params
        end
      end

      it 'gets logged in AuditLog' do
        expected.to change(AuditLog, :count).by(1)
      end
    end
  end
end
