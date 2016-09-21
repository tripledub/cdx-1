require 'spec_helper'
require 'policy_spec_helper'

describe RequestedTestsController  do
  let!(:institution) { Institution.make }
  let!(:user)        { institution.user }
  let!(:site)        { institution.sites.make }
  let!(:patient) do
    Patient.make(
      institution: institution,
      core_fields: { "gender" => "male" },
      custom_fields: { "custom" => "patient value" },
      plain_sensitive_data: { "name": "Doe" }
    )
  end
  let(:encounter)        { Encounter.make institution: institution, site: site ,patient: patient }
  let(:requested_test1)  { RequestedTest.make encounter: encounter }
  let(:requested_test2)  { RequestedTest.make encounter: encounter }
  let(:default_params)   { { context: institution.uuid } }
  let(:jsondata)         {
    {
      "0" => {
        'id'      => requested_test1.id,
        'status'  => 'rejected',
        'comment' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
      }
    }
  }

  describe "update" do
    context 'with a logged user' do
      before :each do
        sign_in user
      end

      it "should update requestedTests status" do
        jsondata =
            {
              "0" => {
                "id" => requested_test1.id,
                "status" => "inprogress",
                "comment" => "comment xyz"
              }
            }

        post :update,  id: encounter.id, requested_tests: jsondata
        encounter.reload
        test = RequestedTest.find(requested_test1.id)

        expect(RequestedTest.statuses[test.status]).to eq RequestedTest.statuses["inprogress"]
        expect(Encounter.statuses[encounter.status]).to eq Encounter.statuses["inprogress"]
        expect(test.comment).to eq 'comment xyz'
      end

      it "should update encounter status to completed ehen test status is complete" do
        jsondata =
            {
              "0" => {
                "id" => requested_test1.id,
                "status" => "completed"
              }
            }

        post :update,  id: encounter.id, requested_tests: jsondata
        test = RequestedTest.find(requested_test1.id)

        updated_encounter = Encounter.find(encounter.id)
        expect(RequestedTest.statuses[test.status]).to eq RequestedTest.statuses["completed"]
        expect(Encounter.statuses[updated_encounter.status]).to eq Encounter.statuses["completed"]
      end

      it "should update encounter status to inprogress when test status is inprogress" do
        jsondata =
            {
              "0" => {
                "id" => requested_test1.id,
                "status" => "inprogress"
              }
            }

        post :update,  id: encounter.id, requested_tests: jsondata
        test = RequestedTest.find(requested_test1.id)
        updated_encounter = Encounter.find(encounter.id)

        expect(RequestedTest.statuses[test.status]).to eq RequestedTest.statuses["inprogress"]
        expect(Encounter.statuses[updated_encounter.status]).to eq Encounter.statuses["inprogress"]
      end

      it "should update audit log" do
        jsondata = {
          "0" => {
            "id" => requested_test1.id,
            "status" => "inprogress"
          }
        }

        post :update,  id: encounter.id, requested_tests: jsondata

        expect(AuditLog.count).to eq 1
        expect(AuditLog.first.title).to eq 'Requested test CD4 has been updated'
      end

      context 'when status is set to rejected' do
        context 'when there is a comment' do
          before :each do
            jsondata = {
              "0" => {
                "id" => requested_test1.id,
                "status" => "rejected",
                "comment" => "comment xyz"
              },
              "1" => {
                "id" => requested_test2.id,
                "status" => "rejected",
                "comment" => "comment 123"
              }
            }

            post :update,  id: encounter.id, requested_tests: jsondata
            requested_test1.reload
            encounter.reload
          end

          it "should update encounter status to completed when test status is rejected" do
            expect(requested_test1.status).to eq 'rejected'
            expect(encounter.status).to eq 'completed'
          end

          it 'should return ok' do
            expect(response.status).to eq(200)
          end
        end

        context 'when there is no comment' do
          before :each do
            jsondata['0'].delete('comment')
            post :update,  id: encounter.id, requested_tests: jsondata, format: :json
          end

          it 'should return an error' do
            expect(response.status).to eq(422)
          end
        end
      end
    end

    context 'if user is not authorised' do
      before :each do
        sign_in Institution.make.user
        post :update,  id: encounter.id, requested_tests: jsondata, format: :json
      end

      it 'should return an error' do
        expect(response.status).to eq(302)
      end
    end
  end
end
