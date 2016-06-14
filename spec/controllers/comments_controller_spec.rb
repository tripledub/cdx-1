require 'spec_helper'
require 'policy_spec_helper'

describe CommentsController do
  render_views
  let(:institution)    { Institution.make }
  let(:user)           { institution.user }
  let(:patient)        { Patient.make institution: institution }
  let(:default_params) { { context: institution.uuid } }
  let(:valid_params)   { {
    description:  'New valid comment',
    comment:      'For whom the bell tolls'
  } }

  before(:each) do
    sign_in user
  end

  describe 'create' do
    context 'with valid data' do
      before :each do
        post :create, patient_id: patient.id, comment: valid_params
      end

      it 'should save the comment' do
        comment = patient.comments.where(description: 'New valid comment').first

        expect(comment.user).to     eq(user)
        expect(comment.uuid).not_to be_empty
        expect(comment.comment).to  eq('For whom the bell tolls')
      end

      it 'should redirect to the patients page' do
        expect(response).to redirect_to patient_path(patient)
      end
    end

    describe 'comment date' do
      context 'if no date is provided ' do
        it 'should add today as default date' do
          post :create, patient_id: patient.id, comment: valid_params
          comment = patient.comments.where(description: 'New valid comment').first

          expect(comment.commented_on).to eq(Date.today)
        end
      end

      context 'if a date is provided' do
        it 'should be saved' do
          post :create, patient_id: patient.id, comment: valid_params.merge!({ commented_on: '11/26/2016' })

          comment = patient.comments.where(description: 'New valid comment').first

          expect(comment.commented_on).to eq(Date.new(2016, 11, 26))
        end
      end
    end

    context 'with invalid data' do
      it 'should render the edit page' do
        post :create, patient_id: patient.id, comment: { comment: 'Invalid' }

        expect(response).to render_template('new')
      end
    end
  end
end
