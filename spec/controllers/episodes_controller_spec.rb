require 'spec_helper'

RSpec.describe EpisodesController, type: :controller do
  render_views
  let(:institution)    { Institution.make }
  let(:user)           { institution.user }
  let(:patient)        { Patient.make institution: institution }
  let(:default_params) { { context: institution.uuid } }

  before(:each) do
    sign_in user
  end

  describe '#new' do
    before do
      get :new, patient_id: patient.id
    end

    it 'can be accessed' do
      expect(response).to be_succes
    end
  end
end
