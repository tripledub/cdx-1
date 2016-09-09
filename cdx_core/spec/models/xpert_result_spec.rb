require 'spec_helper'

describe XpertResult do
  let(:institution)    { Institution.make }
  let(:user)           { institution.user }
  let(:site)           { institution.sites.make }
  let(:patient)        { Patient.make( institution: institution) }
  let(:encounter)      { Encounter.make institution: institution, site: site ,patient: patient }
  let(:requested_test) { RequestedTest.make encounter: encounter }

  context "validations" do
    it { should belong_to(:requested_test) }
    it { should validate_presence_of(:requested_test_id) }
    it { should validate_presence_of(:sample_collected_on) }
    it { should validate_presence_of(:tuberculosis) }
    it { should validate_presence_of(:rifampicin) }
    it { should validate_presence_of(:examined_by) }
    it { should validate_presence_of(:result_on) }

    context 'rifampicin' do
      context 'if is detected and tuberculosis is not detected' do
        subject { XpertResult.new requested_test_id: requested_test.id, result_on: 3.days.from_now, examined_by: 'The doctor', sample_collected_on: 1.day.ago, tuberculosis: 'not_detected', rifampicin: 'detected' }

        it 'should not be valid' do
          expect(subject.valid?).to be false

          expect(subject.errors.messages[:rifampicin].first).to eq("It's not possible to select Rifampicin as detected unless M. tuberculosis has been detected.")
        end
      end

      context 'if is detected and tuberculosis is detected' do
        subject { XpertResult.new requested_test_id: requested_test.id, result_on: 3.days.from_now, examined_by: 'The doctor', sample_collected_on: 1.day.ago, tuberculosis: 'detected', rifampicin: 'detected' }

        it 'should be valid' do
          expect(subject.valid?).to be
        end
      end
    end
  end
end
