require 'spec_helper'
require 'policy_spec_helper'

describe CommentsController do
  render_views
  let(:user)           { User.make }
  let!(:institution)   { user.institutions.make }
  let!(:site) { Site.make institution: institution }
  let(:patient)        { Patient.make institution: institution, site: site }
  let(:default_params) { { context: institution.uuid } }
  let(:valid_params) do
    {
      description:  'New valid comment',
      comment:      'For whom the bell tolls'
    }
  end

  context 'user with edit patient permission' do
    before(:each) do
      sign_in user
    end

    describe 'index' do
      before :each do
        7.times { Comment.make patient: patient }
      end

      it 'should return a json with comments' do
        get 'index', patient_id: patient.id

        expect(JSON.parse(response.body)['rows'].size).to eq(7)
      end

      it 'should return a json with comments ordered by comment date ascending' do
        first_comment = patient.comments.order(:created_at).first
        get 'index', patient_id: patient.id

        expect(JSON.parse(response.body)['rows'].first['title']).to eq(first_comment.description)
      end

      it 'should return a json with comments ordered by user name ascending' do
        first_user = User.where.not(id: user.id).order(first_name: :desc).first
        get 'index', patient_id: patient.id, order_by: '-users.first_name'

        expect(JSON.parse(response.body)['rows'].first['commenter']).to eq(first_user.full_name)
      end

      it 'should return a json with comments ordered by user name ascending' do
        first_user = User.where.not(id: user.id).order(first_name: :asc).first
        get 'index', patient_id: patient.id, order_by: 'users.first_name'

        expect(JSON.parse(response.body)['rows'].first['commenter']).to eq(first_user.full_name)
      end
    end

    describe 'new' do
      it 'should render the new template' do
        get 'new', patient_id: patient.id

        expect(response).to render_template('new')
      end
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

        context 'audited data do' do
          before :each do
            @audit_log = AuditLog.where(patient: patient).first
          end

          it 'should audit the comment' do
            expect(@audit_log.comment).to eq('For whom the bell tolls')
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

    describe 'show' do
      let(:comment) { Comment.make patient: patient }

      it 'should render the show template' do
        get 'show', patient_id: patient.id, id: comment.id

        expect(response).to render_template('show')
      end
    end
  end

  context 'user with no edit patient permission' do
    let(:invalid_user) { Institution.make.user }

    before(:each) do
      grant user, invalid_user, institution, READ_INSTITUTION

      sign_in invalid_user
    end

    describe 'new' do
      it 'should deny access' do
        get 'new', patient_id: patient.id

        expect(response).to redirect_to(patient_path(patient))
      end
    end

    describe 'create' do
      it 'should deny access' do
        post :create, patient_id: patient.id, comment: valid_params

        expect(response).to redirect_to(patient_path(patient))
      end
    end

    describe 'show' do
      let(:comment) { Comment.make patient: patient }

      it 'should not deny access and redirect' do
        get 'show', patient_id: patient.id, id: comment.id

        expect(response).to_not redirect_to(patient_path(patient))
      end
    end
  end
end
